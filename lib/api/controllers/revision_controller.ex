defmodule Api.RevisionController do
  use Api, :controller

  alias Db.VersionControl
  alias Db.VersionControl.Revision
  alias Db.VersionControl.Project
  alias Api.Auth.Token

  action_fallback Api.FallbackController

  def show(conn, %{"revision_id" => id}) do
    with user_id <- Token.current_subject(conn),
         {:ok, revision} <- VersionControl.get_revision(id, user_id),
      do: conn |> put_status(:ok) |> render("show.v1.json", revision: revision)
  end

  def create(conn, %{"revision_id" => id, "project_id" => project_id, "revision" => attrs}) do
    with user_id <- Token.current_subject(conn),
         attrs <- Map.put(attrs, "id", id),
         {:ok, %Project{}} <- VersionControl.get_project(project_id, user_id),
         attrs <- Map.put(attrs, "project_id", project_id),
         {:ok, %Revision{}} <- VersionControl.create_revision(attrs),
      do: conn |> send_resp(:created, "") |> halt()
  end
end
