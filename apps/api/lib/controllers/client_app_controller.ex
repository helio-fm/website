defmodule Api.ClientAppController do
  use Api, :controller
  @moduledoc false

  alias Db.Clients
  alias Db.Clients.App

  action_fallback Api.FallbackController

  def get_client_info(conn, %{"app" => app_name}) do
    with {:ok, clients} <- Clients.get_clients_by_name(app_name),
      {:ok, resources} <- Clients.get_clients_resources_info(app_name),
     do: render(conn, "clients.info.v1.json", clients: clients, resources: resources)
  end

  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:read]}] when action in [:index]
  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:write]}] when action in [:create_or_update]

  def index(conn, _params) do
    apps = Clients.list_apps()
    render(conn, "index.v1.json", apps: apps)
  end

  def create_or_update(conn, %{"app" => app_params}) do
    with {:ok, %App{} = app} <- Clients.create_or_update_app(app_params) do
      conn
      |> put_status(:ok)
      # |> put_resp_header("location", api_client_app_info_path(conn, :get_client_info, app.app_name))
      |> render("show.v1.json", app: app)
    end
  end
end
