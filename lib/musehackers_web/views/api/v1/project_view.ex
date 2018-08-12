defmodule MusehackersWeb.Api.V1.ProjectView do
  use MusehackersWeb, :view
  alias MusehackersWeb.Api.V1.ProjectView
  alias MusehackersWeb.Api.V1.RevisionView

  def render("index.json", %{projects: projects}) do
    %{data: render_many(projects, ProjectView, "project.json")}
  end

  def render("show.json", %{project: project}) do
    %{data: render_one(project, ProjectView, "project.json")}
  end

  def render("show_heads.json", %{heads: heads}) do
    %{data: render_many(heads, RevisionView, "revision.json")}
  end

  def render("project.json", %{project: project}) do
    %{id: project.id,
      title: project.title,
      alias: project.alias,
      head: project.head,
      link: TODO}
  end
end
