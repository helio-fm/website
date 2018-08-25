defmodule Api.RevisionView do
  use Api, :view
  alias Api.RevisionView

  def render("index.v1.json", %{revisions: revisions}) do
    %{data: render_many(revisions, RevisionView, "revision.v1.json")}
  end

  def render("show.v1.json", %{revision: revision}) do
    %{data: render_one(revision, RevisionView, "revision.v1.json")}
  end

  def render("revision.v1.json", %{revision: revision}) do
    %{id: revision.id,
      hash: revision.hash,
      message: revision.message,
      parent_id: revision.parent_id,
      data: revision.data}
  end

  def render("brief.v1.json", %{revision: revision}) do
    %{id: revision.id,
      hash: revision.hash,
      message: revision.message,
      parent_id: revision.parent_id}
  end
end
