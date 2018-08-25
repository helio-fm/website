defmodule Api.AuthSessionController do
  use Api, :controller
  @moduledoc false

  alias Db.Clients
  alias Db.Clients.AuthSession
  import Web.Router.Helpers

  action_fallback Api.FallbackController

  # Use %{assigns: %{version: :v2}} = conn for future versions
  def init_client_auth_session(conn, %{"app" => _app_name, "session" => session}) do
    Clients.delete_auth_session(session["provider"], session["device_id"])
    with {:ok, %AuthSession{} = auth_session} <- Clients.create_auth_session(session) do
      conn
        |> put_status(:created)
        |> put_resp_header("location", auth_confirmation_path(conn, :confirmation, session: auth_session.id))
        |> render("show.v1.json", auth_session: auth_session)
    end
  end

  def finalise_client_auth_session(conn, %{"app" => app_name, "session" => session}) do
    session_id = session["id"]
    session_secret = session["secret_key"]
    auth_session = Clients.get_auth_session!(session_id) # throws 404
    cond do
      auth_session.secret_key != session_secret ->
        conn |> send_resp(:forbidden, "") |> halt()
      AuthSession.is_unfinished(auth_session) ->
        conn |> send_resp(:no_content, "") |> halt()
      AuthSession.is_stale(auth_session) ->
        Clients.delete_auth_session(auth_session)
        conn |> send_resp(:gone, "") |> halt()
      String.downcase(auth_session.app_name) != String.downcase(app_name) ->
        Clients.delete_auth_session(auth_session)
        conn |> send_resp(:conflict, "") |> halt()
      true ->
        Clients.delete_auth_session(auth_session)
        conn
          |> put_status(:ok)
          |> render("finalise.v1.json", auth_session: auth_session)
    end
  end
end
