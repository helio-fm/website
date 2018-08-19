defmodule Web.AuthPageController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use Web, :controller

  plug Ueberauth
  alias Ueberauth.Strategy.Helpers

  alias Api.Auth.Token
  alias Api.Auth.UserFromAuth

  alias Db.Clients
  alias Db.Clients.AuthSession
  alias Db.Accounts.Session

  import Web
  plug :assign_custom_css, custom_css: "user.css"

  def confirmation(conn, %{"session" => auth_session_id}) do
    try do
      client_auth_session = Clients.get_auth_session!(auth_session_id)
      cond do
        !AuthSession.is_unfinished(client_auth_session) ->
          conn |> render("index.html", auth_session: nil, current_user: nil)
        AuthSession.is_stale(client_auth_session) ->
          conn |> render("index.html", auth_session: nil, current_user: nil)
        true ->
          conn
            |> put_session(:client_auth, client_auth_session.id)
            |> render("index.html", auth_session: client_auth_session, current_user: nil)
      end
    rescue
      _any -> conn |> redirect(to: "/") |> halt()
    end
  end

  def confirmation(conn, _params) do
    conn |> redirect(to: "/")
  end

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
      |> configure_session(drop: true)
      |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params),
    do: delete_session_and_redirect(conn)

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    session_id = get_session(conn, :client_auth)
    login_user_for_session_id(conn, auth, session_id)
  end

  defp login_user_for_session_id(conn, _, nil), do: delete_session_and_redirect(conn)
  defp login_user_for_session_id(conn, nil, _), do: delete_session_and_redirect(conn)
  defp login_user_for_session_id(conn, auth, session_id) do
    auth_session = Clients.get_auth_session!(session_id)
    with {:ok, user} <- UserFromAuth.find_or_create(auth),
         {:ok, permissions} <- Token.get_permissions_for(user),
         {:ok, jwt, _full_claims} <- Token.encode_and_sign(user, %{}, permissions: permissions),
         {:ok, jwt} <- Session.update_token_for_device(user.id, auth_session.device_id, auth_session.app_platform, jwt),
         {:ok, _updated_session} <- Clients.finalise_auth_session(auth_session, jwt)
    do
      conn
        |> delete_session(:client_auth)
        |> render("index.html", current_user: user, auth_session: auth_session)
    else
      {:error, _reason} -> delete_session_and_redirect(conn)
    end
  end

  defp delete_session_and_redirect(conn) do
    conn
      |> delete_session(:client_auth)
      |> redirect(to: "/")
  end
end
