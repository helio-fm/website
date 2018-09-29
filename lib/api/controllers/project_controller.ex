defmodule Api.ProjectController do
  use Api, :controller

  alias Db.VersionControl
  alias Db.VersionControl.Project
  alias Api.Auth.Token

  action_fallback Api.FallbackController

  def summary(conn, %{"id" => id}) do
    project = VersionControl.get_project!(id)
    conn |> put_status(:ok) |> render("show.v1.json", project: project)
  end

  def heads(conn, %{"id" => id}) do
    with {:ok, heads} <- VersionControl.get_project_heads(id) do
      conn
      |> put_status(:ok)
      |> render("show.heads.v1.json", heads: heads)
    end
  end

  def create_or_update(conn, %{"id" => id, "project" => project_params}) do
    project_params = Map.put(project_params, "id", id)
    with user_id <- Token.current_subject(conn),
         attrs <- Map.put(project_params, "author_id", user_id),
         {:ok, %Project{} = project} <- VersionControl.create_or_update_project(attrs) do
      conn
      |> put_status(:ok)
      |> render("show.v1.json", project: project)
    end
  end

  def delete(conn, %{"id" => id}) do
    with user_id <- Token.current_subject(conn),
         {:ok, project} = VersionControl.get_project(id, user_id),
         {:ok, %Project{}} <- VersionControl.delete_project(project) do
      send_resp(conn, :no_content, "")
    end
  end

  def index(conn, %{}) do
    with user_id <- Token.current_subject(conn),
         {:ok, projects} <- VersionControl.get_projects_for_user(user_id) do
      conn
      |> put_status(:ok)
      |> render("index.v1.json", projects: projects)
    end
  end
end
