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

  def create_or_update(conn, %{"id" => id, "project" => project_params}) do
    # TODO get author_id from token
    # check if id matchese params?
    with {:ok, %Project{} = project} <- VersionControl.create_or_update_project(project_params) do
      conn
      |> put_status(:ok)
      |> render("show.json", project: project)
    end
  end
end
