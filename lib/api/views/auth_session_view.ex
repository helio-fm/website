defmodule Api.AuthSessionView do
  use Api, :view
  alias Api.AuthSessionView

  def render("show.v1.json", %{auth_session: auth_session}) do
    %{session: render_one(auth_session, AuthSessionView, "auth.session.v1.json")}
  end

  def render("finalise.v1.json", %{auth_session: auth_session}) do
    %{session: render_one(auth_session, AuthSessionView, "auth.token.v1.json")}
  end

  def render("auth.session.v1.json", %{auth_session: auth_session}) do
    %{id: auth_session.id,
      secret_key: auth_session.secret_key,
      token: auth_session.token,
      provider: auth_session.provider,
      device_id: auth_session.device_id,
      app_name: auth_session.app_name,
      app_version: auth_session.app_version,
      app_platform: auth_session.app_platform}
  end

  def render("auth.token.v1.json", %{auth_session: auth_session}) do
    %{token: auth_session.token}
  end
end
