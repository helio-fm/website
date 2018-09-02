defmodule Api.ClientAppResourceView do
  use Api, :view
  @moduledoc false

  def render("resource.data.v1.json", %{resource: resource}) do
    %{data: resource.data}
  end
end
