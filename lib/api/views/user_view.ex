defmodule Api.UserView do
  @moduledoc false

  @users_base_url Application.get_env(:musehackers, :users_base_url)
  @images_base_url Application.get_env(:musehackers, :images_base_url)

  use Api, :view
  alias Api.UserView
  alias Api.ProjectView
  alias Api.SessionView
  alias Api.UserResourceView

  def render("index.v1.json", %{users: users}) do
    %{userProfile: render_many(users, UserView, "user.v1.json",
      %{sessions: [], resources: [], projects: []})}
  end

  def render("show.v1.json", %{user: user, sessions: sessions, resources: resources, projects: projects}) do
    %{userProfile: render_one(user, UserView, "user.v1.json",
      %{sessions: sessions, resources: resources, projects: projects})}
  end

  def render("user.v1.json", %{user: user, sessions: sessions, resources: user_resources, projects: projects}) do
    %{login: user.login,
      name: user.name,
      profile_url: @users_base_url <> user.login,
      avatar: get_avatar_url(user),
      projects: render_many(projects, ProjectView, "project.v1.json"),
      sessions: render_many(sessions, SessionView, "session.info.v1.json"),
      resources: render_many(user_resources, UserResourceView, "resource.info.v1.json")}
  end

  defp get_avatar_url(user) do
    if user.avatar, do: @images_base_url <> user.avatar, else: nil
  end
end
