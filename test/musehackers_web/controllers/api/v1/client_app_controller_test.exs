defmodule MusehackersWeb.ClientAppControllerTest do
  use MusehackersWeb.ConnCase

  alias Musehackers.Clients
  alias Musehackers.Accounts.User
  alias Musehackers.Auth.Token

  @create_attrs %{
    app_name: "some app_name",
    link: "some link",
    platform_id: "some platform_id",
    version: "some version"
  }

  @update_attrs %{
    app_name: "some app_name",
    link: "some updated link",
    platform_id: "some platform_id",
    version: "some updated version"
  }

  @invalid_attrs %{app_name: nil, link: nil, platform_id: nil, version: nil}

  def fixture(:app) do
    {:ok, app} = Clients.create_or_update_app(@create_attrs)
    app
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all apps", %{conn: conn} do
      conn = get authenticated(conn), api_v1_client_list_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create app versions" do
    test "renders client info when data is valid", %{conn: conn} do
      conn = post authenticated(conn), api_v1_client_update_path(conn, :create_or_update), app: @create_attrs
      assert json_response(conn, 200)["data"] != %{}

      conn = post authenticated(conn), api_v1_client_update_path(conn, :create_or_update), app: %{@create_attrs | platform_id: "some platform_id 2"}
      assert json_response(conn, 200)["data"] != %{}

      conn = get authenticated(conn), api_v1_client_app_info_path(conn, :get_client_info, @create_attrs.app_name)
      assert json_response(conn, 200)["data"] == %{
        "resourceInfo" => [],
        "versionInfo" => [%{"link" => "some link",
          "platformId" => "some platform_id",
          "version" => "some version"},
          %{"link" => "some link",
          "platformId" => "some platform_id 2",
          "version" => "some version"}]}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post authenticated(conn), api_v1_client_update_path(conn, :create_or_update), app: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update exisitng app version" do
    test "renders client info when data is valid", %{conn: conn} do
      conn = post authenticated(conn), api_v1_client_update_path(conn, :create_or_update), app: @create_attrs
      assert json_response(conn, 200)["data"] != %{}

      conn = post authenticated(conn), api_v1_client_update_path(conn, :create_or_update), app: @update_attrs
      assert json_response(conn, 200)["data"] != %{}

      conn = get authenticated(conn), api_v1_client_app_info_path(conn, :get_client_info, @create_attrs.app_name)
      assert json_response(conn, 200)["data"] == %{
        "resourceInfo" => [],
        "versionInfo" => [%{
          "link" => "some updated link",
          "platformId" => "some platform_id",
          "version" => "some updated version"}]}
    end
  end

  defp authenticated(conn) do
    user = %User{id: "11111111-1111-1111-1111-111111111111", password: "admin"}
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: %{admin: [:read, :write]})
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
