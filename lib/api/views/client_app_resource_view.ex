defmodule Api.ClientAppResourceView do
  use Api, :view
  @moduledoc false

  def render("resource.data.v1.json", %{resource: resource}) do
    %{data: resource.data}
  end

  def render("resource.info.v1.json", %{resource: resource}) do
    %{type: resource.type,
      hash: resource.hash}
  end
end
