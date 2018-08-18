defmodule MusehackersWeb.Api.ClientAppView do
  use MusehackersWeb, :view
  alias MusehackersWeb.Api.ClientAppView
  @moduledoc false

  def render("index.v1.json", %{apps: apps}) do
    %{data: render_many(apps, ClientAppView, "app.v1.json", as: :app)}
  end

  def render("show.v1.json", %{app: app}) do
    %{data: render_one(app, ClientAppView, "app.v1.json", as: :app)}
  end

  def render("app.v1.json", %{app: app}) do
    %{platform_id: app.platform_id,
      version: app.version,
      link: app.link}
  end

  def render("clients.info.v1.json", %{clients: clients, resources: resources}) do
    %{data: %{
      version_info: render_many(clients, ClientAppView, "client.info.v1.json", as: :client),
      resource_info: render_many(resources, ClientAppView, "resource.info.v1.json", as: :resource)}}
  end

  def render("client.info.v1.json", %{client: client}) do
    %{platform_id: client.platform_id,
      version: client.version,
      link: client.link}
  end

  def render("resource.info.v1.json", %{resource: resource}) do
    %{resource_name: resource.resource_name,
      hash: resource.hash}
  end
end
