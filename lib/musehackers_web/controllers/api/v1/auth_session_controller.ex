defmodule MusehackersWeb.Api.V1.AuthSessionController do
  use MusehackersWeb, :controller
  @moduledoc false

  alias Musehackers.Clients
  alias Musehackers.Clients.AuthSession

  action_fallback MusehackersWeb.Api.V1.FallbackController

  def init_client_auth_session(conn, %{"app" => app_name, "session" => session}) do
    Clients.delete_auth_session(session["provider"], session["device_id"])
    with {:ok, %AuthSession{} = auth_session} <- Clients.create_auth_session(session) do
      conn
        |> put_status(:created)
        |> put_resp_header("location", auth_confirmation_path(conn, :confirmation, session: auth_session.id))
        |> render("show.json", auth_session: auth_session)
    end
  end

  def finalise_client_auth_session(conn, %{"app" => app_name, "session" => session_id}) do
    # will throw and return 404, if auth with such id and key does not exist:
    with {:ok, %AuthSession{} = auth_session} <- Clients.get_auth_session!(session_id) do
      cond do
        auth_session.token == nil ->
          conn |> send_resp(:no_content, "") |> halt()
        DateTime.diff(auth_session.updated_at, DateTime.utc_now) > 600 ->
          Clients.delete_auth_session(auth_session)
          conn |> send_resp(:gone, "") |> halt()
        auth_session.app_name != app_name ->
          Clients.delete_auth_session(auth_session)
          conn |> send_resp(:conflict, "") |> halt()
        true ->
          Clients.delete_auth_session(auth_session)
          conn
            |> put_status(:ok)
            |> render("finalise.json", auth_session: auth_session)
      end
    end
  end
end
