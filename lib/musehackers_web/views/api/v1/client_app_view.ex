defmodule MusehackersWeb.Api.V1.ClientAppView do
  use MusehackersWeb, :view
  alias MusehackersWeb.Api.V1.ClientAppView
  @moduledoc false

  def render("index.json", %{resources: resources}) do
    %{data: render_many(resources, ClientAppView, "resource.json", as: :resource)}
  end

  def render("show.json", %{resource: resource}) do
    %{data: render_one(resource, ClientAppView, "resource.json", as: :resource)}
  end

  def render("resource.json", %{resource: resource}) do
    %{id: resource.id,
      resource_name: resource.resource_name,
      app_name: resource.app_name,
      hash: resource.hash,
      data: resource.data}
  end

  def render("resource_data.json", %{resource: resource}) do
    resource.data
  end
end
