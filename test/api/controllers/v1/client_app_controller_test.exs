defmodule Api.V1.ClientAppControllerTest do
  use Api.ConnCase

  alias Db.Clients
  alias Db.Accounts.User
  alias Api.Auth.Token

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/helio.fm.v1+json")}
  end

  @create_attrs %{
    app_name: "helio",
    build_type: "portable",
    branch: "stable",
    architecture: "all",
    link: "some link",
    platform_type: "platform_type",
    version: "2.0"
  }

  @update_attrs %{
    app_name: "helio",
    build_type: "portable",
    branch: "stable",
    architecture: "all",
    link: "some updated link",
    platform_type: "platform_type",
    version: "2.1"
  }

  @invalid_attrs %{app_name: nil, link: nil, platform_type: nil, version: nil}

  describe "get client info" do
    test "renders error on unauthenticated request to get client info", %{conn: conn} do
      conn = get conn, api_client_app_info_path(conn, :get_client_info, @create_attrs.app_name)
      assert response(conn, 401)
    end

    test "renders error on request to get info for unknown client", %{conn: conn} do
      conn = get client(conn, "noname"), api_client_app_info_path(conn, :get_client_info, "noname")
      assert response(conn, 404)
    end
  end

  describe "create app versions" do
    test "renders client info when data is valid", %{conn: conn} do
      conn = post authenticated(conn), api_client_app_version_path(conn, :update_app_version), app: @create_attrs
      assert json_response(conn, 200)["clientApp"] != %{}

      conn = post authenticated(conn), api_client_app_version_path(conn, :update_app_version), app: %{@create_attrs | platform_type: "platform_type 2"}
      assert json_response(conn, 200)["clientApp"] != %{}

      conn = post authenticated(conn), api_client_app_version_path(conn, :update_app_version), app: %{@create_attrs | platform_type: "platform_type 2"}

      Clients.create_or_update_resource(%{app_name: @create_attrs.app_name, data: %{}, type: "some type"})

      conn = get client(conn), api_client_app_info_path(conn, :get_client_info, @create_attrs.app_name)
      assert %{"resources" => [%{"type" => "some type", "hash" => _}],
        "versions" => [%{"link" => "some link",
          "platformType" => "platform_type",
          "version" => "2.0"},
          %{"link" => "some link",
          "platformType" => "platform_type 2",
          "version" => "2.0"}]} = json_response(conn, 200)["clientApp"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post authenticated(conn), api_client_app_version_path(conn, :update_app_version), app: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update exisitng app version" do
    test "renders client info when data is valid", %{conn: conn} do
      conn = post authenticated(conn), api_client_app_version_path(conn, :update_app_version), app: @create_attrs
      assert json_response(conn, 200)["clientApp"] != %{}

      conn = post authenticated(conn), api_client_app_version_path(conn, :update_app_version), app: @update_attrs
      assert json_response(conn, 200)["clientApp"] != %{}

      conn = get client(conn), api_client_app_info_path(conn, :get_client_info, @create_attrs.app_name)
      assert %{"resources" => [], "versions" => [%{
          "link" => "some updated link",
          "platformType" => "platform_type",
          "version" => "2.1"}]} = json_response(conn, 200)["clientApp"]
    end
  end

  defp authenticated(conn) do
    user = %User{id: "11111111-1111-1111-1111-111111111111", password: "admin"}
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: %{admin: [:read, :write]})
    conn
      |> recycle
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> put_req_header("user-agent", "helio")
  end

  defp client(conn, client \\ "Helio") do
    conn
      |> recycle
      |> put_req_header("user-agent", client)
  end
end
