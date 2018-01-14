defmodule MusehackersWeb.SessionController do
  use MusehackersWeb, :controller
  @moduledoc false

  alias Musehackers.Guardian
  alias Musehackers.Accounts.User

  action_fallback MusehackersWeb.FallbackController

  def sign_in(conn, %{"session" => %{"email" => email, "password" => pass}}) do
    with {:ok, user} <- User.find_and_confirm_password(email, pass),
         {:ok, jwt, _full_claims} <- Guardian.encode_and_sign(user, %{}),
    # token_type: :api ?
    # override token_ttl: {1, :hour} for api tokens?
    do: render(conn, "sign_in.json", user: user, jwt: jwt)
  end
end
