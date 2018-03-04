defmodule Musehackers.Jobs.Etl.Helpers do
  require Logger
  use Tesla
  @moduledoc false

  plug Tesla.Middleware.Headers, %{"Accept" => "text/csv,application/csv,text/xml,application/xml,application/json"}
  plug Tesla.Middleware.Opts, [recv_timeout: :infinity]
  plug Tesla.Middleware.FollowRedirects, max_redirects: 10

  @type url :: String.t

  @spec download(url()) :: {:ok, String.t} | {:error, atom()}
  def download(url) do
    with {:ok, url} <- check_content(url),
         %Tesla.Env{status: 200, body: body} <- fetch(url) do
            {:ok, body}
    end
  end

  @spec check_content(String.t) :: {:ok, String.t} | {:error, term()}
  @doc """
  This helper checks the MIME type of the page. It first sends a `HEAD` request, and according to
  the HTTP Code (301 or 302, for instance), decides to probe the new location of the page,
  or just return the url in an :ok-tuple
  """
  def check_content(url) do
    response = url
               |> head
               |> check_response

    result = with  {:ok, headers} <- response,
                   types          <- Map.get(headers, "content-type"),
                   :ok            <-  verify_mime(types) do
                    {:ok, url}
            else
              {:moved, location} -> check_content(location)
              {:error, err}      -> {:error, err}
            end
    result
  end

  defp check_response(%Tesla.Env{status: code, body: _data, headers: headers}) do
    case code do
      code when code in [301, 302] ->
        location = Map.get(headers, "location")
        {:moved, location}
      _  ->
        {:ok, headers}
    end
  end

  @spec fetch(String.t) :: {:ok, %Tesla.Env{}} | {:error, %Tesla.Env{}}
  def fetch(url) do
    get(url)
  end

  @spec verify_mime(String.t) :: :ok | {:error, :wrong_headers}
  defp verify_mime(types) do
    case Regex.run(~r/^(?:text|application)\/(?:json|xml|csv).*/iu, types, capture: :all_but_first) do
      nil -> {:error, :wrong_headers}
      _   -> :ok
    end
  end
end
