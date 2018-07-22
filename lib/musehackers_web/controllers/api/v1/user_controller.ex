defmodule MusehackersWeb.Api.V1.UserController do
  use MusehackersWeb, :controller
  @moduledoc false

  alias Musehackers.Accounts
  alias Musehackers.Accounts.User

  action_fallback MusehackersWeb.Api.V1.FallbackController

  plug Guardian.Plug.LoadResource, ensure: true

  def get_current_user(conn, _params) do
    with user = Guardian.Plug.current_resource(conn),
      do: render(conn, "show.json", user: user)
  end

  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:read]}] when action in [:index, :show]
  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:write]}] when action in [:create, :update, :delete]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{}} <- Accounts.delete_user(user) do
      conn |> send_resp(:no_content, "") |> halt()
    end
  end
end
