defmodule Api.ClientAppView do
  @moduledoc false

  use Api, :view
  alias Api.ClientAppView

  def render("client.info.v1.json", %{versions: versions, resources: resources}) do
    %{clientApp: %{
      versions: render_many(versions, ClientAppView, "version.info.v1.json", as: :version),
      resources: render_many(resources, ClientAppView, "resource.info.v1.json", as: :resource)}}
  end

  def render("resource.data.v1.json", %{resource: resource}) do
    %{data: resource.data}
  end

  def render("resource.info.v1.json", %{resource: resource}) do
    %{type: resource.type,
      hash: resource.hash}
  end

  def render("version.info.v1.json", %{version: version}) do
    %{platform_type: version.platform_type,
      build_type: version.build_type,
      branch: version.branch,
      architecture: version.architecture,
      version: version.version,
      link: version.link}
  end
end
