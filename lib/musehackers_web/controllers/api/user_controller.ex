defmodule MusehackersWeb.Api.UserController do
  use MusehackersWeb, :controller
  @moduledoc false

  alias Musehackers.Accounts
  alias Musehackers.Accounts.User

  action_fallback MusehackersWeb.Api.FallbackController

  plug Guardian.Plug.LoadResource, ensure: true

  def get_current_user(%{assigns: %{version: :v1}} = conn, _params) do
    with user <- Guardian.Plug.current_resource(conn),
      do: render(conn, "show.v1.json", user: user)
  end

  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:read]}] when action in [:index, :show]
  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:write]}] when action in [:create, :update, :delete]

  def index(%{assigns: %{version: :v1}} = conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.v1.json", users: users)
  end

  def delete(%{assigns: %{version: :v1}} = conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{}} <- Accounts.delete_user(user) do
      conn |> send_resp(:no_content, "") |> halt()
    end
  end
end
