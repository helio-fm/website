defmodule Api.UserResourceController do
  use Api, :controller

  alias Db.Accounts
  alias Db.Accounts.Resource
  alias Api.Auth.Token

  action_fallback Api.FallbackController

  def show(conn, %{"type" => type, "name" => name}) do
    with user_id <- Token.current_subject(conn),
         {:ok, resource} <- Accounts.get_resource_for_user(user_id, type, name),
      do: conn |> render("resource.v1.json", user_resource: resource)
  end

  def create_or_update(conn, %{"type" => type, "name" => name, "resource" => params}) do
    params = params |> Map.put("type", type) |> Map.put("name", name)
    with user_id <- Token.current_subject(conn),
         attrs <- Map.put(params, "owner_id", user_id),
         {:ok, %Resource{} = resource} <- create_or_update_resource(user_id, type, name, attrs),
      do: conn |> render("resource.info.v1.json", user_resource: resource)
  end

  defp create_or_update_resource(user_id, type, name, attrs) do
    with {:ok, %Resource{}} <- Accounts.get_resource_for_user(user_id, type, name) do
      Accounts.update_resource(attrs)
    else
      {:error, :resource_not_found} ->
        Accounts.create_resource(attrs)
    end
  end

  def delete(conn, %{"type" => type, "name" => name}) do
    with user_id <- Token.current_subject(conn),
         {:ok, %Resource{} = resource} <- Accounts.get_resource_for_user(user_id, type, name),
         {:ok, %Resource{}} <- Accounts.delete_resource(resource),
      do: conn |> send_resp(:no_content, "")
  end
end
