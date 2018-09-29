defmodule Api.UserResourceController do
  use Api, :controller

  alias Db.Accounts
  alias Db.Accounts.Resource
  alias Api.Auth.Token

  action_fallback Api.FallbackController

  def get_user_resource(conn, %{"type" => type, "name" => name}) do
    with user_id <- Token.current_subject(conn),
         {:ok, resource} <- Accounts.get_resource_for_user(user_id, type, name),
      do: render(conn, "resource.v1.json", user_resource: resource)
  end

  def update_user_resource(conn, %{"type" => type, "name" => name, "resource" => resource_params}) do
    with user_id <- Token.current_subject(conn),
         {:ok, %Resource{} = resource} <- Accounts.create_or_update_resource(%{resource_params | owner_id: user_id}),
      do: render(conn, "resource.v1.json", user_resource: resource)
  end

  # def delete(conn, %{"type" => type, "name" => name}) do
  #   resource = Accounts.get_resource!(id)
  #   with {:ok, %Resource{}} <- Accounts.delete_resource(resource),
  #     do: send_resp(conn, :no_content, "")
  # end
end
