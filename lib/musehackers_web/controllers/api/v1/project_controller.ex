defmodule MusehackersWeb.Api.V1.ProjectController do
  use MusehackersWeb, :controller

  alias Musehackers.VersionControl
  alias Musehackers.VersionControl.Project

  action_fallback MusehackersWeb.Api.V1.FallbackController

  def summary(conn, %{"id" => id}) do
    project = VersionControl.get_project!(id)
    conn |> put_status(:ok) |> render("show.json", project: project)
  end

  def heads(conn, %{"id" => id}) do
    with {:ok, heads} <- VersionControl.get_project_heads(id) do
      conn
      |> put_status(:ok)
      |> render("show_heads.json", heads: heads)
    end
  end

  plug Guardian.Plug.LoadResource, ensure: true

  def create_or_update(conn, %{"id" => id, "project" => project_params}) do
    # TODO check id?
    with user <- Guardian.Plug.current_resource(conn),
        attrs <- Map.put(project_params, "author_id", user.id),
        {:ok, %Project{} = project} <- VersionControl.create_or_update_project(attrs) do
      conn
      |> put_status(:ok)
      |> render("show.json", project: project)
    end
  end
end
