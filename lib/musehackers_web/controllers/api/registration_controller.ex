defmodule MusehackersWeb.Api.RegistrationController do
  use MusehackersWeb, :controller
  @moduledoc false

  alias Musehackers.Accounts
  alias Musehackers.Accounts.User

  action_fallback MusehackersWeb.Api.FallbackController

  def sign_up(%{assigns: %{version: :v1}} = conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.register_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", api_user_path(conn, :get_current_user))
      |> render("registration.success.v1.json", user: user)
    end
  end
end
