defmodule Web.HelioClientPageController do
  use Web, :controller
  @moduledoc false

  import Plug.Conn
  alias Db.Clients
  alias Db.Clients.AppVersion

  def index(conn, _params) do
    user_agent = case get_req_header(conn, "user-agent") do
        [] -> ""
        nil -> ""
        header -> header |> List.first
    end

    platform = case AppVersion.detect_platform(user_agent) do
      {:ok, value} -> value
      {:error, _} -> "windows" # as default
    end

    architecture = AppVersion.detect_architecture(user_agent)

    clients = case Clients.get_latest_app_versions("helio", "%") do
        {:ok, clients_info} -> clients_info |> add_readable_file_size_info_if_any
        _ -> []
    end

    render conn, "index.html",
        latest_releases: clients,
        suggested_releases: clients
          |> filter_stable_builds_for(platform)
          |> add_dev_build_if_empty(clients, platform),
        platform: platform,
        architecture: architecture
  end

  defp add_readable_file_size_info_if_any(clients_info) do
    clients_info |> Enum.map(fn(x) -> x |> Map.merge(%{
      file_info: readable_filesize(x.file_size)
    }) end)
  end

  defp filter_stable_builds_for(all_clients, platform) do
    Enum.filter(all_clients, fn(x) ->
      String.downcase(x.platform_type) == platform && x.branch == "stable"
    end)
  end

  defp add_dev_build_if_empty([], all_clients, platform) do
    case Enum.find(all_clients, fn(x) ->
      String.downcase(x.platform_type) == platform && x.branch != "stable" end) do
      nil -> []
      build -> [build]
    end
  end

  defp add_dev_build_if_empty(releases, _, _), do: releases

  @bytes ~w(B KB MB GB TB PB)

  defp readable_filesize(0), do: ""
  defp readable_filesize(value) do
    value = value / 1 # cast to float
    ceil = 1024

    {exponent, _rem} = :math.log(value) / :math.log(ceil)
      |> Float.floor |> Float.to_string |> Integer.parse

    result = Float.round(value / :math.pow(ceil, exponent), 1)
    {:ok, unit} = Enum.fetch(@bytes, exponent)

    Enum.join([result, unit], " ")
  end
end
