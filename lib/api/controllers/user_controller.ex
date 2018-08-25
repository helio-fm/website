defmodule Api.UserController do
  use Api, :controller
  @moduledoc false

  alias Db.Accounts
  alias Db.Accounts.User

  action_fallback Api.FallbackController

  plug Guardian.Plug.LoadResource, ensure: true

  def get_current_user(conn, _params) do
    with user <- Guardian.Plug.current_resource(conn),
      do: render(conn, "show.v1.json", user: user)
  end

  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:read]}] when action in [:index, :show]
  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:write]}] when action in [:create, :update, :delete]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.v1.json", users: users)
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{}} <- Accounts.delete_user(user) do
      conn |> send_resp(:no_content, "") |> halt()
    end
  end
end
