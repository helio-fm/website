defmodule Api.ProjectView do
  @moduledoc false

  use Api, :view
  alias Api.ProjectView
  alias Api.RevisionView

  def render("index.v1.json", %{projects: projects}) do
    %{projects: render_many(projects, ProjectView, "project.v1.json")}
  end

  def render("show.v1.json", %{project: project}) do
    %{project: render_one(project, ProjectView, "project.v1.json")}
  end

  def render("show.revisions.v1.json", %{project: project, revisions: revisions}) do
    %{project:
      %{id: project.id,
        title: project.title,
        alias: project.alias,
        head: project.head,
        updated_at: project.updated_at,
        revisions: render_many(revisions, RevisionView, "brief.v1.json")}}
  end

  def render("project.v1.json", %{project: project}) do
    %{id: project.id,
      title: project.title,
      alias: project.alias,
      head: project.head,
      updated_at: project.updated_at}
  end
end
