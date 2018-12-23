defmodule Api.ProjectController do
  use Api, :controller

  alias Db.VersionControl
  alias Db.VersionControl.Project
  alias Api.Auth.Token

  action_fallback Api.FallbackController

  def summary(conn, %{"project_id" => id}) do
    with user_id <- Token.current_subject(conn),
         {:ok, project} <- VersionControl.get_project(id, user_id),
         {:ok, revisions} <- VersionControl.get_revisions_summary(project),
      do: conn |> put_status(:ok) |> render("show.revisions.v1.json", project: project, revisions: revisions)
  end

  def create_or_update(conn, %{"project_id" => id, "project" => params}) do
    params = params |> Map.put("id", id)
    with user_id <- Token.current_subject(conn),
         attrs <- Map.put(params, "author_id", user_id),
         {:ok, %Project{} = project} <- create_or_update_project(id, user_id, attrs),
      do: conn |> put_status(:ok) |> render("show.v1.json", project: project)
  end

  defp create_or_update_project(id, user_id, attrs) do
    with {:ok, %Project{}} <- VersionControl.get_project(id, user_id) do
      VersionControl.update_project(attrs)
    else
      {:error, :project_not_found} ->
        VersionControl.create_project(attrs)
    end
  end

  def delete(conn, %{"project_id" => id}) do
    with user_id <- Token.current_subject(conn),
         {:ok, project} <- VersionControl.get_project(id, user_id),
         {:ok, %{project: %Project{}, revisions: _}} <- VersionControl.delete_project(project),
      do: conn |> send_resp(:no_content, "")
  end

  def index(conn, %{}) do
    with user_id <- Token.current_subject(conn),
         {:ok, projects} <- VersionControl.get_projects_for_user(user_id),
      do: conn |> put_status(:ok) |> render("index.v1.json", projects: projects)
  end
end
