defmodule MusehackersWeb.AuthPageControllerTest do
  use MusehackersWeb.ConnCase

  alias Musehackers.Clients
  alias Musehackers.Clients.AuthSession

  describe "redirects when no session provided" do
    test "redirects", %{conn: conn} do
      conn = get conn, auth_confirmation_path(conn, :confirmation, %{session: UUID.uuid4()})
      assert response(conn, 302)
    end
  end

  describe "renders auth page" do
    setup [:create_session]

    test "renders auth page with valid unfinished session", %{conn: conn, auth_session: %AuthSession{id: id}} do
      conn = get conn, auth_confirmation_path(conn, :confirmation, %{session: id})
      assert html_response(conn, 200) =~ "Sign in with Github"
    end

    test "renders error with valid finished session", %{conn: conn, auth_session: %AuthSession{id: id} = session} do
      Clients.finalise_auth_session(session, "token")
      conn = get conn, auth_confirmation_path(conn, :confirmation, %{session: id})
      assert html_response(conn, 200) =~ "Not today, sir"
    end
  end

  @create_attrs %{
    provider: "Github",
    app_name: "helio",
    app_platform: "some app_platform",
    app_version: "some app_version",
    device_id: "some device_id",
    secret_key: "to be overridden",
    token: "to be reset to nil"
  }

  defp create_session(_) do
    auth_session = fixture(:auth_session)
    {:ok, auth_session: auth_session}
  end

  defp fixture(:auth_session) do
    {:ok, auth_session} = Clients.create_auth_session(@create_attrs)
    auth_session
  end
end
