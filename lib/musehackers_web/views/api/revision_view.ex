defmodule MusehackersWeb.Api.RevisionView do
  use MusehackersWeb, :view
  alias MusehackersWeb.Api.RevisionView

  def render("index.json", %{revisions: revisions}) do
    %{data: render_many(revisions, RevisionView, "revision.json")}
  end

  def render("show.json", %{revision: revision}) do
    %{data: render_one(revision, RevisionView, "revision.json")}
  end

  def render("show_brief.json", %{revision: revision}) do
    %{data: render_one(revision, RevisionView, "brief.json")}
  end

  def render("revision.json", %{revision: revision}) do
    %{id: revision.id,
      hash: revision.hash,
      message: revision.message,
      parent_id: revision.parent_id,
      data: revision.data}
  end

  def render("brief.json", %{revision: revision}) do
    %{id: revision.id,
      hash: revision.hash,
      message: revision.message,
      parent_id: revision.parent_id}
  end
end
