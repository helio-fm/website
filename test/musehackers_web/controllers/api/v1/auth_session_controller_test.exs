defmodule MusehackersWeb.Api.V1.AuthSessionControllerTest do
  use MusehackersWeb.ConnCase

  alias Musehackers.Clients
  alias Musehackers.Clients.AuthSession

  @create_attrs %{
    session: %{
      provider: "Github",
      app_name: "helio",
      app_platform: "some app_platform",
      app_version: "some app_version",
      device_id: "some device_id",
      secret_key: "to be overridden",
      token: "to be reset to nil"
    }
  }

  @invalid_attrs %{
    session: %{
      app_name: nil,
      app_platform: nil,
      app_version: nil,
      secret_key: nil,
      token: nil
    }
  }

  describe "init auth_session" do
    test "renders auth_session when data is valid", %{conn: conn} do
      conn = post client(conn), api_v1_client_auth_init_path(conn, :init_client_auth_session, "helio", @create_attrs)
      assert json_response(conn, :created)["data"]["provider"] == "Github"
      assert json_response(conn, :created)["data"]["appName"] == "helio"
      assert json_response(conn, :created)["data"]["appPlatform"] == "some app_platform"
      assert json_response(conn, :created)["data"]["appVersion"] == "some app_version"
      assert json_response(conn, :created)["data"]["deviceId"] == "some device_id"
      assert json_response(conn, :created)["data"]["token"] == ""
      assert json_response(conn, :created)["data"]["id"] != ""
      assert json_response(conn, :created)["data"]["secretKey"] != ""
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post client(conn), api_v1_client_auth_init_path(conn, :init_client_auth_session, "helio", @invalid_attrs)
      assert response(conn, :unprocessable_entity)
    end

    test "renders errors when not authenticated", %{conn: conn} do
      conn = post conn, api_v1_client_auth_init_path(conn, :init_client_auth_session, "helio", @create_attrs)
      assert response(conn, :unauthorized)
    end

    test "renders 404 when trying to finalise non-existent session", %{conn: conn} do
      assert_error_sent :not_found, fn ->
        post client(conn), api_v1_client_auth_finalise_path(conn, :finalise_client_auth_session, "helio"), [session: UUID.uuid4()]
      end
    end
  end

  describe "finalise auth_session" do
    setup [:create_auth_session]

    test "renders token and deletes the finalised auth session", %{conn: conn, auth_session: %AuthSession{id: id} = auth_session} do
      token = UUID.uuid4()
      Clients.finalise_auth_session(auth_session, token)
      conn = post client(conn), api_v1_client_auth_finalise_path(conn, :finalise_client_auth_session, "helio", %{session: id})
      assert json_response(conn, :ok)["data"]["token"] == token

      assert_error_sent :not_found, fn ->
        post client(conn), api_v1_client_auth_finalise_path(conn, :finalise_client_auth_session, "helio", %{session: id})
      end
    end

    test "renders no_content when existing session has no token", %{conn: conn, auth_session: %AuthSession{id: id}} do
      conn = post client(conn), api_v1_client_auth_finalise_path(conn, :finalise_client_auth_session, "helio"), [session: id]
      assert response(conn, :no_content)
    end

    test "renders confilct and deletes auth session when app name does not match", %{conn: conn, auth_session: %AuthSession{id: id} = auth_session} do
      Clients.finalise_auth_session(auth_session, "token")
      conn = post client(conn), api_v1_client_auth_finalise_path(conn, :finalise_client_auth_session, "other", %{session: id})
      assert response(conn, :conflict)

      assert_error_sent :not_found, fn ->
        post client(conn), api_v1_client_auth_finalise_path(conn, :finalise_client_auth_session, "helio", %{session: id})
      end
    end
  end

  defp create_auth_session(_) do
    auth_session = fixture(:auth_session)
    {:ok, auth_session: auth_session}
  end

  defp fixture(:auth_session) do
    {:ok, auth_session} = Clients.create_auth_session(@create_attrs.session)
    auth_session
  end

  defp client(conn) do
    conn
      |> recycle
      |> put_req_header("client", "helio")
  end
end
