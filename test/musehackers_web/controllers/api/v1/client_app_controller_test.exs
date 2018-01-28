defmodule MusehackersWeb.ClientAppControllerTest do
  use MusehackersWeb.ConnCase

  alias Musehackers.Clients
  alias Musehackers.Clients.App

  @create_attrs %{
    app_name: "some app_name",
    link: "some link",
    platform_id: "some platform_id",
    version: "some version"
  }

  @update_attrs %{
    app_name: "some updated app_name",
    link: "some updated link",
    platform_id: "some updated platform_id",
    version: "some updated version"
  }

  @invalid_attrs %{app_name: nil, link: nil, platform_id: nil, version: nil}

  def fixture(:app) do
    {:ok, app} = Clients.create_app(@create_attrs)
    app
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all apps", %{conn: conn} do
      conn = get conn, api_v1_client_app_info_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create app" do
    test "renders app when data is valid", %{conn: conn} do
      conn = post conn, api_v1_client_app_info_path(conn, :create), app: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, api_v1_client_app_info_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "app_name" => "some app_name",
        "link" => "some link",
        "platform_id" => "some platform_id",
        "version" => "some version"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, api_v1_client_app_info_path(conn, :create), app: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update app" do
    setup [:create_app]

    test "renders app when data is valid", %{conn: conn, app: %App{id: id} = app} do
      conn = put conn, api_v1_client_app_info_path(conn, :update, app), app: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, api_v1_client_app_info_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "app_name" => "some updated app_name",
        "link" => "some updated link",
        "platform_id" => "some updated platform_id",
        "version" => "some updated version"}
    end

    test "renders errors when data is invalid", %{conn: conn, app: app} do
      conn = put conn, api_v1_client_app_info_path(conn, :update, app), app: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete app" do
    setup [:create_app]

    test "deletes chosen app", %{conn: conn, app: app} do
      conn = delete conn, api_v1_client_app_info_path(conn, :delete, app)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, api_v1_client_app_info_path(conn, :show, app)
      end
    end
  end

  defp create_app(_) do
    app = fixture(:app)
    {:ok, app: app}
  end
end
