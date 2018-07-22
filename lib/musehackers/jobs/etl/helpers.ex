defmodule Musehackers.Jobs.Etl.Helpers do
  require Logger
  use Tesla
  @moduledoc false

  plug Tesla.Middleware.Headers, [{"Accept", "text/csv,application/csv,text/xml,application/xml,application/json"}]
  plug Tesla.Middleware.Opts, [recv_timeout: :infinity]
  plug Tesla.Middleware.FollowRedirects, max_redirects: 10

  def download(url) do
    with {:ok, url} <- check_content(url),
         {:ok, %Tesla.Env{status: 200, body: body}} <- get(url) do
            {:ok, body}
    end
  end

  defp check_content(url) do
    response = url |> head |> check_response
    with {:ok, env} <- response,
         types <- Tesla.get_header(env, "content-type"),
         :ok <- verify_mime(types) do
      {:ok, url}
    else
      {:moved, location} -> check_content(location)
      {:error, err} -> {:error, err}
    end
  end

  defp check_response({:ok, %Tesla.Env{status: code} = env}) do
    case code do
      code when code in [301, 302] ->
        {:moved, Tesla.get_header(env, "location")}
      _  ->
        {:ok, env}
    end
  end

  defp verify_mime(types) do
    case Regex.run(~r/^(?:text|application)\/(?:json|xml|csv).*/iu, types, capture: :all_but_first) do
      nil -> {:error, :wrong_headers}
      _   -> :ok
    end
  end
end
