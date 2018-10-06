defmodule Api.RevisionController do
  use Api, :controller

  alias Db.VersionControl
  alias Db.VersionControl.Revision
  alias Db.VersionControl.Project
  alias Api.Auth.Token

  action_fallback Api.FallbackController

  def show(conn, %{"id" => id}) do
    with user_id <- Token.current_subject(conn),
         {:ok, revision} <- VersionControl.get_revision(id, user_id),
      do: conn |> put_status(:ok) |> render("show.v1.json", revision: revision)
  end

  def create(conn, %{"id" => id, "revision" => revision_params}) do
    with user_id <- Token.current_subject(conn),
         attrs <- Map.put(revision_params, "id", id),
         project_id <- Map.get(attrs, "project_id"),
         {:ok, %Project{}} <- VersionControl.get_project(project_id, user_id),
         {:ok, %Revision{}} <- VersionControl.create_revision(attrs),
      do: conn |> send_resp(:created, "") |> halt()
  end
end
