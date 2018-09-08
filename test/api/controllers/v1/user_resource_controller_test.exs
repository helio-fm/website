defmodule Api.V1.UserResourceControllerTest do
  use Api.ConnCase

  # alias Db.Accounts
  # alias Db.Accounts.Resource

  # @create_attrs %{data: %{}, hash: "some hash", type: "some type"}
  # @update_attrs %{data: %{}, hash: "some updated hash", type: "some updated type"}
  # @invalid_attrs %{data: nil, hash: nil, type: nil}

  # def fixture(:resource) do
  #   {:ok, resource} = Accounts.create_resource(@create_attrs)
  #   resource
  # end

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end

  # describe "index" do
  #   test "lists all user_resources", %{conn: conn} do
  #     conn = get conn, resource_path(conn, :index)
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  # describe "create resource" do
  #   test "renders resource when data is valid", %{conn: conn} do
  #     conn = post conn, resource_path(conn, :create), resource: @create_attrs
  #     assert %{"id" => id} = json_response(conn, 201)["data"]

  #     conn = get conn, resource_path(conn, :show, id)
  #     assert json_response(conn, 200)["data"] == %{
  #       "id" => id,
  #       "data" => %{},
  #       "hash" => "some hash",
  #       "type" => "some type"}
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post conn, resource_path(conn, :create), resource: @invalid_attrs
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "update resource" do
  #   setup [:create_resource]

  #   test "renders resource when data is valid", %{conn: conn, resource: %Resource{id: id} = resource} do
  #     conn = put conn, resource_path(conn, :update, resource), resource: @update_attrs
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get conn, resource_path(conn, :show, id)
  #     assert json_response(conn, 200)["data"] == %{
  #       "id" => id,
  #       "data" => %{},
  #       "hash" => "some updated hash",
  #       "type" => "some updated type"}
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, resource: resource} do
  #     conn = put conn, resource_path(conn, :update, resource), resource: @invalid_attrs
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete resource" do
  #   setup [:create_resource]

  #   test "deletes chosen resource", %{conn: conn, resource: resource} do
  #     conn = delete conn, resource_path(conn, :delete, resource)
  #     assert response(conn, 204)
  #     assert_error_sent 404, fn ->
  #       get conn, resource_path(conn, :show, resource)
  #     end
  #   end
  # end

  # defp create_resource(_) do
  #   resource = fixture(:resource)
  #   {:ok, resource: resource}
  # end
end
