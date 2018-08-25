defmodule Api.SessionController do
  use Api, :controller
  @moduledoc false

  alias Api.Auth.Token
  alias Db.Accounts.User
  alias Db.Accounts.Session

  action_fallback Api.FallbackController

  def sign_in(conn, %{"session" => %{"email" => email, "password" => pass,
    "device_id" => device_id, "platform_id" => platform_id}}) do
    with {:ok, user} <- User.find_and_confirm_password(email, pass),
         {:ok, permissions} <- Token.get_permissions_for(user),
         {:ok, jwt, _full_claims} <- Token.encode_and_sign(user, %{}, permissions: permissions),
         {:ok, jwt} <- Session.update_token_for_device(user.id, device_id, platform_id, jwt),
    do: render(conn, "sign.in.v1.json", user: user, jwt: jwt)
  end

  def refresh_token(conn, %{"session" => %{"bearer" => old_token,
    "device_id" => device_id, "platform_id" => platform_id}}) do
    with {:ok, user} <- User.find_user_for_session(device_id, old_token),
         {:ok, permissions} <- Token.get_permissions_for(user),
         {:ok, jwt, _full_claims} <- Token.encode_and_sign(user, %{}, permissions: permissions),
         {:ok, jwt} <- Session.update_token_for_device(user.id, device_id, platform_id, jwt),
    do: render(conn, "refresh.token.v1.json", user: user, jwt: jwt)
  end

  def is_authenticated(conn, _params) do
    conn
    |> put_status(:ok)
    |> render(Api.SessionView, "session.status.v1.json")
  end
end
