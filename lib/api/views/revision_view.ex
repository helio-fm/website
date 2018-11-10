defmodule Api.RevisionView do
  use Api, :view
  alias Api.RevisionView

  def render("show.v1.json", %{revision: revision}) do
    %{revision: render_one(revision, RevisionView, "revision.v1.json")}
  end

  def render("revision.v1.json", %{revision: revision}) do
    %{id: revision.id,
      message: revision.message,
      timestamp: revision.timestamp,
      parent_id: revision.parent_id,
      data: revision.data}
  end

  def render("brief.v1.json", %{revision: revision}) do
    %{id: revision.id,
      message: revision.message,
      timestamp: revision.timestamp,
      parent_id: revision.parent_id}
  end
end
