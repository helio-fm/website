defmodule Api.ClientAppView do
  @moduledoc false

  use Api, :view
  alias Api.ClientAppView
  alias Api.ClientAppResourceView

  def render("show.v1.json", %{app: app}) do
    %{client_app: render_one(app, ClientAppView, "app.v1.json", as: :app)}
  end

  def render("app.v1.json", %{app: app}) do
    %{platform_id: app.platform_id,
      version: app.version,
      link: app.link}
  end

  def render("clients.info.v1.json", %{clients: clients, resources: resources}) do
    %{clientApp: %{
      versions: render_many(clients, ClientAppView, "client.info.v1.json", as: :client),
      resources: render_many(resources, ClientAppResourceView, "resource.info.v1.json", as: :resource)}}
  end

  def render("client.info.v1.json", %{client: client}) do
    %{platform_id: client.platform_id,
      version: client.version,
      link: client.link}
  end
end
