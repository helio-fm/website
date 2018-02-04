defmodule MusehackersWeb.Api.V1.ClientAppView do
  use MusehackersWeb, :view
  alias MusehackersWeb.Api.V1.ClientAppView
  @moduledoc false

  def render("index.json", %{apps: apps}) do
    %{data: render_many(apps, ClientAppView, "app.json", as: :app)}
  end

  def render("show.json", %{app: app}) do
    %{data: render_one(app, ClientAppView, "app.json", as: :app)}
  end

  def render("app.json", %{app: app}) do
    %{id: app.id,
      app_name: app.app_name,
      platform_id: app.platform_id,
      version: app.version,
      link: app.link}
  end
end
