defmodule Api.UserResourceView do
  use Api, :view
  @moduledoc false

  def render("resource.v1.json", %{user_resource: resource}) do
    %{type: resource.type,
      name: resource.name,
      hash: resource.hash,
      data: resource.data}
  end

  def render("resource.info.v1.json", %{user_resource: resource}) do
    %{type: resource.type,
      name: resource.name,
      hash: resource.hash,
      updated_at: resource.updated_at}
  end
end
