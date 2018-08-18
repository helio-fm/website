defmodule MusehackersWeb.Api.ClientResourceView do
  use MusehackersWeb, :view
  @moduledoc false

  def render("resource_data.json", %{resource: resource}) do
    %{data: resource.data}
  end
end
