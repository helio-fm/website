defmodule Api.ProjectView do
  @moduledoc false

  use Api, :view
  alias Api.ProjectView
  alias Api.RevisionView

  def render("index.v1.json", %{projects: projects}) do
    %{data: render_many(projects, ProjectView, "project.v1.json")}
  end

  def render("show.v1.json", %{project: project}) do
    %{data: render_one(project, ProjectView, "project.v1.json")}
  end

  def render("show.heads.v1.json", %{heads: heads}) do
    %{data: render_many(heads, RevisionView, "brief.v1.json")}
  end

  def render("project.v1.json", %{project: project}) do
    %{id: project.id,
      title: project.title,
      alias: project.alias,
      head: project.head,
      updated_at: project.updated_at}
  end
end
