defmodule Api.Auth.CheckToken do
  @moduledoc false
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline, otp_app: :musehackers,
                              module: Api.Auth.Token,
                              error_handler: Api.Auth.ErrorHandler

  plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated

  # We want stateless authentication, so no user is loaded from DB at this point.
  # Any controller that needs current_resource(conn) should LoadResource explicitly.
  # plug Guardian.Plug.LoadResource, ensure: true
end
