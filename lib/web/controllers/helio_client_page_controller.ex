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
        {:ok, clients_info} -> clients_info
        _ -> []
    end

    render conn, "index.html",
        clients: clients,
        platform: platform,
        architecture: architecture
  end
end
