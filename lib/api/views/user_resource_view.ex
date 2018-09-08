defmodule Api.UserResourceView do
  use Api, :view
  alias Api.UserResourceView

  def render("index.v1.json", %{user_resources: user_resources}) do
    %{data: render_many(user_resources, UserResourceView, "resource.json")}
  end

  def render("show.v1.json", %{resource: resource}) do
    %{data: render_one(resource, UserResourceView, "resource.json")}
  end

  def render("resource.v1.json", %{resource: resource}) do
    %{type: resource.type,
      name: resource.name,
      hash: resource.hash,
      data: resource.data}
  end

  def render("resource.info.v1.json", %{resource: resource}) do
    %{type: resource.type,
      name: resource.name,
      hash: resource.hash}
  end
end
