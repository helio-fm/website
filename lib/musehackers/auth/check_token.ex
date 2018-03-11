defmodule Musehackers.Auth.CheckToken do
  @moduledoc false
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline, otp_app: :musehackers,
                              module: Musehackers.Auth.Token,
                              error_handler: Musehackers.Auth.ErrorHandler

  plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true
end
