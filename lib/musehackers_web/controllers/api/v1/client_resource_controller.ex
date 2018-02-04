defmodule MusehackersWeb.Api.V1.ClientResourceController do
  use MusehackersWeb, :controller
  @moduledoc false

  alias Musehackers.Clients
  alias Musehackers.Clients.Resource

  action_fallback MusehackersWeb.Api.V1.FallbackController

  def index(conn, _params) do
    resources = Clients.list_resources()
    render(conn, "index.json", resources: resources)
  end

  def create(conn, %{"resource" => resource_params}) do
    with {:ok, %Resource{} = resource} <- Clients.create_resource(resource_params) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", api_v1_client_resource_path(conn, :show, resource))
      |> render("show.json", resource: resource)
    end
  end

  def show(conn, %{"id" => id}) do
    resource = Clients.get_resource!(id)
    render(conn, "show.json", resource: resource)
  end

  def update(conn, %{"id" => id, "resource" => resource_params}) do
    resource = Clients.get_resource!(id)

    with {:ok, %Resource{} = resource} <- Clients.update_resource(resource, resource_params) do
      render(conn, "show.json", resource: resource)
    end
  end

  def delete(conn, %{"id" => id}) do
    resource = Clients.get_resource!(id)
    with {:ok, %Resource{}} <- Clients.delete_resource(resource) do
      send_resp(conn, :no_content, "")
    end
  end
end
