defmodule MusehackersWeb.RegistrationControllerTest do
  use MusehackersWeb.ConnCase

  @data %{email: "email@helio.fm", name: "some name", phone: "some phone", password: "some password", password_confirmation: "some password"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register user" do
    test "registers user when data is valid", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: @data
      assert %{"status" => "ok"} = json_response(conn, 201)
    end

    test "renders errors when no data provided", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: %{}
      assert response(conn, 422)
    end

    test "renders errors when no name provided", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: %{@data | name: nil}
      assert json_response(conn, 422)["errors"]["name"] != ""
    end

    test "renders errors when no phone provided", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: %{@data | phone: nil}
      assert json_response(conn, 422)["errors"]["phone"] != ""
    end

    test "renders errors when no email provided", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: %{@data | email: nil}
      assert json_response(conn, 422)["errors"]["email"] != ""
    end

    test "renders errors when invalid email provided", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: %{@data | email: "no_at_character"}
      assert json_response(conn, 422)["errors"]["email"] != ""
    end

    test "renders errors when already existing email provided", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: @data
      conn = post conn, registration_path(conn, :sign_up), user: @data
      assert "has already been taken" in json_response(conn, 422)["errors"]["email"]
    end

    test "renders errors when no password provided", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: %{@data | password: nil}
      assert json_response(conn, 422)["errors"]["password"] != ""
    end

    test "renders errors when password confirmation doesn't match password", %{conn: conn} do
      conn = post conn, registration_path(conn, :sign_up), user: %{@data | password_confirmation: "mismatch"}
      assert json_response(conn, 422)["errors"]["password_confirmation"] != ""
    end
  end
end
