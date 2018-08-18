defmodule MusehackersWeb.Api.ClientResourceView do
  use MusehackersWeb, :view
  @moduledoc false

  def render("resource.data.v1.json", %{resource: resource}) do
    %{data: resource.data}
  end
end
