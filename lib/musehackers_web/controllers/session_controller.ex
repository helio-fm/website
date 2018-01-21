defmodule MusehackersWeb.SessionController do
  use MusehackersWeb, :controller
  @moduledoc false

  alias Musehackers.Guardian
  # alias Musehackers.Accounts
  alias Musehackers.Accounts.User
  # alias Musehackers.Accounts.Session

  action_fallback MusehackersWeb.FallbackController

  def sign_in(conn, %{"session" => %{"email" => email, "password" => pass}}) do
    with {:ok, user} <- User.find_and_confirm_password(email, pass),
         {:ok, jwt, _full_claims} <- Guardian.encode_and_sign(user, %{}),
         # {:ok, jwt, session} <- Session.update_token_for_device(user.id, device_id, jwt)
    do: render(conn, "sign_in.json", user: user, jwt: jwt)
  end

  # def refresh_token(conn, %{"session" => %{"bearer" => old_token, "device_id" => device_id}}) do
  #   with {:ok, user} <- Accounts.get_user_with_session(email, old_token, device_id),
  #        {:ok, jwt, _full_claims} <- Guardian.encode_and_sign(user, %{}),
  #        {:ok, session} <- Session.update_token_for_device(user.id, device_id, jwt)
  #   do: render(conn, "refresh_token.json", user: user, jwt: jwt)
  # end
end
