defmodule MusehackersWeb.Api.V1.RegistrationControllerTest do
  use MusehackersWeb.ConnCase

  @data %{
    login: "helio.fm",
    email: "email@helio.fm",
    password: "some password",
    password_confirmation: "some password"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register user" do
    test "registers user when data is valid", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: @data
      assert %{"status" => "ok"} = json_response(conn, 201)
    end

    test "renders errors when no data provided", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{}
      assert response(conn, 422)
    end

    test "renders error when no login provided", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | login: nil}
      assert json_response(conn, 422)["errors"]["login"] != ""
    end

    test "renders error when login is too short", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | login: "qw"}
      assert json_response(conn, 422)["errors"]["login"] != ""
    end

    test "renders error when login is too long", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | login: "qwertyuiopqwertyu"}
      assert json_response(conn, 422)["errors"]["login"] != ""
    end

    test "renders error when login contains unallowed characters", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | login: "qwq!@#$%^&*()w"}
      assert json_response(conn, 422)["errors"]["login"] != ""
    end

    test "renders error when login starts with numeric character", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | login: "4weqwr"}
      assert json_response(conn, 422)["errors"]["login"] != ""
    end

    test "renders error when login starts with dot", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | login: ".wEQwr"}
      assert json_response(conn, 422)["errors"]["login"] != ""
    end

    test "renders error when contains more then one of allowed special characters", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | login: "test.test-test"}
      assert json_response(conn, 422)["errors"]["login"] != ""
    end

    test "renders error when login ends with hyphen", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | login: "test-"}
      assert json_response(conn, 422)["errors"]["login"] != ""
    end

    test "renders error when already existing login provided", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: @data
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | email: "other@email.com"}
      assert "has already been taken" in json_response(conn, 422)["errors"]["login"]
    end

    test "renders error when no email provided", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | email: nil}
      assert json_response(conn, 422)["errors"]["email"] != ""
    end

    test "renders error when invalid email provided", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | email: "no_at_character"}
      assert json_response(conn, 422)["errors"]["email"] != ""
    end

    test "renders error when already provided existing email", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: @data
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | login: "other-login"}
      assert "has already been taken" in json_response(conn, 422)["errors"]["email"]
    end

    test "renders error when already provided same email in different case", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: @data
      conn = post conn, api_v1_registration_path(conn, :sign_up),
        user: %{@data | login: "other-login", email: "eMail@hElio.FM"}

      assert "has already been taken" in json_response(conn, 422)["errors"]["email"]
    end

    test "renders error when no password provided", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | password: nil}
      assert json_response(conn, 422)["errors"]["password"] != ""
    end

    test "renders error when password confirmation doesn't match password", %{conn: conn} do
      conn = post conn, api_v1_registration_path(conn, :sign_up), user: %{@data | password_confirmation: "mismatch"}
      assert json_response(conn, 422)["errors"]["password_confirmation"] != ""
    end
  end
end
