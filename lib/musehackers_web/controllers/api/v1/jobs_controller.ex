defmodule MusehackersWeb.Api.V1.JobsController do
  use MusehackersWeb, :controller
  @moduledoc false

  action_fallback MusehackersWeb.Api.V1.FallbackController

  def update_translations(conn, _params) do
    children = Supervisor.which_children(Musehackers.Jobs.Supervisor)
    pid = children
      |> Enum.filter(fn{name, _, _, _} -> name == Elixir.Musehackers.Jobs.Etl.Translations end)
      |> Enum.map(fn{_, pid, _, _} -> pid end)
      |> List.first
    GenServer.call(pid, :process)
    conn
    |> put_status(:ok)
    |> render(MusehackersWeb.Api.V1.JobsView, "job_status.json")
  end
end
