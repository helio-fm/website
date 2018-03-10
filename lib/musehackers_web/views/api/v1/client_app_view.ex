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
    %{platform_id: app.platform_id,
      version: app.version,
      link: app.link}
  end

  def render("clients_info.json", %{clients: clients, resources: resources}) do
    %{data: %{
      versions: render_many(clients, ClientAppView, "client_info.json", as: :client),
      resources: render_many(resources, ClientAppView, "resource_info.json", as: :resource)}}
  end

  def render("client_info.json", %{client: client}) do
    %{platform_id: client.platform_id,
      version: client.version,
      link: client.link}
  end

  def render("resource_info.json", %{resource: resource}) do
    %{resource_name: resource.resource_name,
      hash: resource.hash}
  end
end
