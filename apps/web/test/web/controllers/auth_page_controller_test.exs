defmodule Web.AuthPageControllerTest do
  use Web.ConnCase

  import Plug.Test

  alias Db.Repo
  alias Db.Clients
  alias Db.Clients.AuthSession
  alias Db.Accounts.User

  setup do
    Tesla.Mock.mock fn
      %{method: :get, url: nil} ->
        %Tesla.Env{status: 404, body: ""}
      %{method: :get, url: "https://www.gravatar.com/avatar/941776d1919efd91813ff21302692467?s=150&d=identicon"} ->
        %Tesla.Env{status: 404, body: ""}
    end
    :ok
  end

  describe "redirects to the root when no session provided" do
    test "redirects", %{conn: conn} do
      conn = get conn, auth_confirmation_path(conn, :confirmation, %{session: UUID.uuid4()})
      assert response(conn, 302)
    end
  end

  describe "renders auth confirmation page" do
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

  describe "authorises user with Github" do
    setup [:create_session]

    test "redirects user to Github for authentication", %{conn: conn} do
      conn = get conn, auth_request_path(conn, :request, "github")
      assert redirected_to(conn, 302)
    end

    @ueberauth_auth %Ueberauth.Auth{
      credentials: %{token: "fdsnoafhnoofh08h38h"}, uid: "rudenko",
      info: %{email: "email@helio.fm", nickname: "rudenko", name: "Peter"},
      provider: :github
    }

    test "does not create user from Github information when session is missing", %{conn: conn} do
      conn = conn
      |> assign(:ueberauth_auth, @ueberauth_auth)
      |> post(auth_callback_path(conn, :callback, "github"))

      users = User |> Repo.all
      assert Enum.empty?(users)
      assert redirected_to(conn, 302)
    end

    test "deletes session on auth failure", %{conn: conn, auth_session: auth_session} do
      conn = conn
      |> init_test_session(client_auth: auth_session.id)
      |> assign(:ueberauth_failure, %{errors: []})
      |> post(auth_callback_path(conn, :callback, "github"))

      assert redirected_to(conn, 302)
      session_id = get_session(conn, :client_auth)
      assert session_id == nil
    end    

    test "creates user from Github information with session being set", %{conn: conn, auth_session: auth_session} do
      conn = conn
      |> init_test_session(client_auth: auth_session.id)
      |> assign(:ueberauth_auth, @ueberauth_auth)
      |> post(auth_callback_path(conn, :callback, "github"))

      users = User |> Repo.all
      assert Enum.count(users) == 1

      assert html_response(conn, 200) =~ "connection is good to go"
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
