defmodule Api.V1.ClientAppControllerTest do
  use Api.ConnCase

  alias Db.Clients

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/helio.fm.v1+json")}
  end

  @valid_attrs [%{
    app_name: "helio",
    platform_type: "linux",
    build_type: "portable",
    branch: "stable",
    architecture: "all",
    version: "2.0",
    link: "some link",
    is_archived: false
  }, %{
    app_name: "helio",
    platform_type: "linux",
    build_type: "portable",
    branch: "develop",
    architecture: "all",
    version: "2.0",
    link: "some link",
    is_archived: false
  }]

  defp apps_fixture(attrs \\ %{}) do
    {:ok, apps} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Clients.update_versions()

    apps
  end

  describe "get client info" do
    test "renders client resources and versions when has a valid data", %{conn: conn} do
      [app, _] = apps_fixture()

      Clients.create_or_update_resource(%{app_name: app.app_name, data: %{}, type: "some type"})

      conn = get client(conn), api_client_app_info_path(conn, :get_client_info, app.app_name)
      assert %{"resources" => [%{"type" => "some type", "hash" => _}],
        "versions" => [%{"link" => "some link",
          "branch" => "develop",
          "platformType" => "linux",
          "version" => "2.0"}, %{"link" => "some link",
          "branch" => "stable",
          "platformType" => "linux",
          "version" => "2.0"}]} = json_response(conn, 200)["clientApp"]
    end

    test "renders error on unauthenticated request to get client info", %{conn: conn} do
      [app, _] = apps_fixture()
      conn = get conn, api_client_app_info_path(conn, :get_client_info, app.app_name)
      assert response(conn, 401)
    end

    test "renders error on request to get info for unknown client", %{conn: conn} do
      conn = get client(conn, "noname on linux"), api_client_app_info_path(conn, :get_client_info, "noname")
      assert response(conn, 404)
    end

    test "renders error on request to get info for unknown platform", %{conn: conn} do
      conn = get client(conn, "yo"), api_client_app_info_path(conn, :get_client_info, "yo")
      assert response(conn, 404) =~ "unknown platform"
    end
  end

  defp client(conn, client \\ "Helio on Linux X 64-bit") do
    conn
      |> recycle
      |> put_req_header("user-agent", client)
  end
end
