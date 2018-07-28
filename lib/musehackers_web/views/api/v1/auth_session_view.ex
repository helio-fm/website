defmodule MusehackersWeb.Api.V1.AuthSessionView do
  use MusehackersWeb, :view
  alias MusehackersWeb.Api.V1.AuthSessionView

  def render("index.json", %{auth_sessions: auth_sessions}) do
    %{data: render_many(auth_sessions, AuthSessionView, "auth_session.json")}
  end

  def render("show.json", %{auth_session: auth_session}) do
    %{data: render_one(auth_session, AuthSessionView, "auth_session.json")}
  end

  def render("auth_session.json", %{auth_session: auth_session}) do
    %{id: auth_session.id,
      secret_key: auth_session.secret_key,
      token: auth_session.token,
      provider: auth_session.provider,
      device_id: auth_session.device_id,
      app_name: auth_session.app_name,
      app_version: auth_session.app_version,
      app_platform: auth_session.app_platform}
  end

  def render("finalise.json", %{auth_session: auth_session}) do
    %{token: auth_session.token}
  end
end
