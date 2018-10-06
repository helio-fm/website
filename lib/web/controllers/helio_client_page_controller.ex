defmodule Web.HelioClientPageController do
  use Web, :controller
  @moduledoc false

  import Plug.Conn
  alias Db.Clients

  @default_platform "windows"

  def index(conn, _params) do
    user_agent = case get_req_header(conn, "user-agent") do
        [] -> @default_platform
        nil -> @default_platform
        header -> header |> List.first
    end

    clients = case Clients.get_app_versions_by_name("helio") do
        {:ok, clients_info} -> clients_info
        _ -> []
    end

    render conn, "index.html",
        clients: clients,
        platform: get_platform(user_agent),
        architecture: get_architecture(user_agent)
  end

  defp get_platform(user_agent) do
    cond do
        String.match?(user_agent, ~r/Android/) ->
            "android"
        String.match?(user_agent, ~r/(iPad|iPhone|iPod)/) ->
            "ios"
        String.match?(user_agent, ~r/Mac OS X/) ->
            "macos"
        String.match?(user_agent, ~r/(Linux|FreeBSD)/) ->
            "linux"
        true ->
            @default_platform
    end
  end

  defp get_architecture(user_agent) do
    if String.match?(user_agent, ~r/(WOW64|Win64|x86_64)/) do
      "amd64"
    else
      "i386"
    end
  end

end
