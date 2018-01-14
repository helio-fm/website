defmodule Musehackers.Guardian.AuthPipeline do
  @moduledoc false
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline, otp_app: :musehackers,
                              module: Musehackers.Guardian,
                              error_handler: Musehackers.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true
end
