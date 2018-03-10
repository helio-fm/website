defmodule MusehackersWeb.Api.V1.ClientResourceView do
  use MusehackersWeb, :view
  @moduledoc false

  def render("resource_data.json", %{resource: resource}) do
    %{data: resource.data}
  end
end
