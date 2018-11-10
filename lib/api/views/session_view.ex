defmodule Api.SessionView do
  use Api, :view
  @moduledoc false

  def render("sign.in.v1.json", %{user: user, jwt: jwt}) do
    %{status: :ok,
      session: %{
        token: jwt,
        email: user.email
      }, message: """
        You are successfully logged in!
        Add this token to authorization header to make authorized requests.
      """}
  end

  def render("refresh.token.v1.json", %{user: user, jwt: jwt}) do
    %{status: :ok,
      message: "Token was successfully re-issued",
      session: %{
        token: jwt,
        email: user.email
      }}
  end

  def render("session.info.v1.json", %{session: session}) do
    %{platform_id: session.platform_id,
      device_id: session.device_id,
      created_at: session.inserted_at,
      updated_at: session.updated_at}
  end

  def render("session.status.v1.json", _params) do
    %{status: :ok}
  end
end
