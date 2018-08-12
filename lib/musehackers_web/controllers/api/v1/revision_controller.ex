defmodule MusehackersWeb.Api.V1.RevisionController do
  use MusehackersWeb, :controller

  alias Musehackers.VersionControl
  alias Musehackers.VersionControl.Revision

  action_fallback MusehackersWeb.Api.V1.FallbackController

  def show(conn, %{"id" => id}) do
    revision = VersionControl.get_revision!(id)
    conn
    |> put_status(:ok)
    |> render("show.json", revision: revision)
  end

  def create(conn, %{"id" => id, "revision" => revision_params}) do
    # TODO check id?
    with attrs <- Map.put(revision_params, "id", id),
        {:ok, %Revision{} = revision} <- VersionControl.create_revision(attrs) do
      conn
      |> send_resp(:created, "")
      |> halt()
    end
  end
end
