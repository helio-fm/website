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
    %{id: resource.id,
      resource_name: resource.resource_name,
      hash: resource.hash,
      data: resource.data}
  end
end
