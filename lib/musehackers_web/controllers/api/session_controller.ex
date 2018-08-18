defmodule MusehackersWeb.Api.SessionController do
  use MusehackersWeb, :controller
  @moduledoc false

  alias Musehackers.Auth.Token
  alias Musehackers.Accounts.User
  alias Musehackers.Accounts.Session

  action_fallback MusehackersWeb.Api.FallbackController

  def sign_in(%{assigns: %{version: :v1}} = conn, %{"session" => %{"email" => email, "password" => pass,
    "device_id" => device_id, "platform_id" => platform_id}}) do
    with {:ok, user} <- User.find_and_confirm_password(email, pass),
         {:ok, permissions} <- Token.get_permissions_for(user),
         {:ok, jwt, _full_claims} <- Token.encode_and_sign(user, %{}, permissions: permissions),
         {:ok, jwt} <- Session.update_token_for_device(user.id, device_id, platform_id, jwt),
    do: render(conn, "sign.in.v1.json", user: user, jwt: jwt)
  end

  def refresh_token(%{assigns: %{version: :v1}} = conn, %{"session" => %{"bearer" => old_token,
    "device_id" => device_id, "platform_id" => platform_id}}) do
    with {:ok, user} <- User.find_user_for_session(device_id, old_token),
         {:ok, permissions} <- Token.get_permissions_for(user),
         {:ok, jwt, _full_claims} <- Token.encode_and_sign(user, %{}, permissions: permissions),
         {:ok, jwt} <- Session.update_token_for_device(user.id, device_id, platform_id, jwt),
    do: render(conn, "refresh.token.v1.json", user: user, jwt: jwt)
  end

  def is_authenticated(%{assigns: %{version: :v1}} = conn, _params) do
    conn
    |> put_status(:ok)
    |> render(MusehackersWeb.Api.SessionView, "session.status.v1.json")
  end
end
