defmodule MusehackersWeb.SessionControllerTest do
  use MusehackersWeb.ConnCase

  @sign_up_payload %{
    login: "helio.fm",
    email: "email@helio.fm",
    first_name: "john",
    last_name: "doe",
    password: "some password",
    password_confirmation: "some password"
  }

  @sign_in_payload %{
    email: "email@helio.fm",
    password: "some password",
    device_id: "some device",
    platform_id: "ios"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register and login" do
    test "registers and logs user in when data is valid", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: @sign_up_payload
      assert %{"status" => "ok"} = json_response(conn, 201)

      conn = post conn, session_path(conn, :sign_in), session: @sign_in_payload
      assert %{"status" => "ok"} = json_response(conn, 200)
      assert json_response(conn, 200)["data"]["token"] != ""
    end

    test "registers and logs user in when data is valid but email case differs", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: @sign_up_payload
      assert %{"status" => "ok"} = json_response(conn, 201)

      conn = post conn, session_path(conn, :sign_in), session: %{@sign_in_payload | email: "email@helio.FM"}
      assert %{"status" => "ok"} = json_response(conn, 200)
      assert json_response(conn, 200)["data"]["token"] != ""
    end

    test "returns valid JWT token that successfully authorizes a protected resource request", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: @sign_up_payload
      assert %{"status" => "ok"} = json_response(conn, 201)

      conn = post conn, session_path(conn, :sign_in), session: @sign_in_payload
      assert %{"status" => "ok"} = json_response(conn, 200)
      assert json_response(conn, 200)["data"]["email"] == "email@helio.fm"

      jwt = json_response(conn, 200)["data"]["token"]
      conn = get authenticated(conn, jwt), user_path(conn, :index)
      assert json_response(conn, 200)["data"] != []
    end

    test "renders login error when email is invalid", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: @sign_up_payload
      assert %{"status" => "ok"} = json_response(conn, 201)

      conn = post conn, session_path(conn, :sign_in), session: %{@sign_in_payload | email: "invalid"}
      assert %{"status" => "unauthorized"} = json_response(conn, 401)
    end

    test "renders login error when password is invalid", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: @sign_up_payload
      assert %{"status" => "ok"} = json_response(conn, 201)

      conn = post conn, session_path(conn, :sign_in), session: %{@sign_in_payload | password: "invalid"}
      assert %{"status" => "unauthorized"} = json_response(conn, 401)
    end
  end

  defp authenticated(conn, jwt) do
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
