defmodule Api.UserResourceController do
  use Api, :controller

  alias Db.Accounts
  alias Db.Accounts.Resource

  action_fallback Api.FallbackController

  def create(conn, %{"resource" => resource_params}) do
    with {:ok, %Resource{} = resource} <- Accounts.create_resource(resource_params) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", user_resource_path(conn, :show, resource))
      |> render("show.v1.json", resource: resource)
    end
  end

  def show(conn, %{"id" => id}) do
    resource = Accounts.get_resource!(id)
    render(conn, "show.v1.json", resource: resource)
  end

  def update(conn, %{"id" => id, "resource" => resource_params}) do
    resource = Accounts.get_resource!(id)

    with {:ok, %Resource{} = resource} <- Accounts.update_resource(resource, resource_params) do
      render(conn, "show.v1.json", resource: resource)
    end
  end

  def delete(conn, %{"id" => id}) do
    resource = Accounts.get_resource!(id)
    with {:ok, %Resource{}} <- Accounts.delete_resource(resource) do
      send_resp(conn, :no_content, "")
    end
  end
end
