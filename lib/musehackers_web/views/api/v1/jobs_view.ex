defmodule MusehackersWeb.Api.V1.JobsView do
  use MusehackersWeb, :view
  @moduledoc false

  def render("job_status.json", _params) do
    %{status: :ok}
  end
end
