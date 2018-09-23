defmodule Api.UserController do
  use Api, :controller
  @moduledoc false

  alias Db.Accounts
  alias Db.VersionControl

  action_fallback Api.FallbackController

  plug Guardian.Plug.LoadResource

  def get_current_user(conn, _params) do
    with user <- Guardian.Plug.current_resource(conn),
      {:ok, projects} <- VersionControl.get_projects_for_user(user),
      {:ok, sessions} <- Accounts.get_sessions_for_user(user),
      {:ok, resources} <- Accounts.get_resources_brief_for_user(user) do
        render(conn, "show.v1.json", user: user, sessions: sessions, resources: resources, projects: projects)
    end
  end
end
