defmodule MusehackersWeb.Api.V1.ClientAppController do
  use MusehackersWeb, :controller
  @moduledoc false

  alias Musehackers.Clients
  alias Musehackers.Clients.App

  action_fallback MusehackersWeb.Api.V1.FallbackController

  def index(conn, _params) do
    apps = Clients.list_apps()
    render(conn, "index.json", apps: apps)
  end

  def create(conn, %{"app" => app_params}) do
    with {:ok, %App{} = app} <- Clients.create_app(app_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", api_v1_client_app_info_path(conn, :show, app))
      |> render("show.json", app: app)
    end
  end

  def show(conn, %{"id" => id}) do
    app = Clients.get_app!(id)
    render(conn, "show.json", app: app)
  end

  def update(conn, %{"id" => id, "app" => app_params}) do
    app = Clients.get_app!(id)

    with {:ok, %App{} = app} <- Clients.update_app(app, app_params) do
      render(conn, "show.json", app: app)
    end
  end

  def delete(conn, %{"id" => id}) do
    app = Clients.get_app!(id)
    with {:ok, %App{}} <- Clients.delete_app(app) do
      send_resp(conn, :no_content, "")
    end
  end
end
