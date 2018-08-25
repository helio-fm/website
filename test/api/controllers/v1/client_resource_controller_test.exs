defmodule Api.V1.ClientResourceControllerTest do
  use Api.ConnCase

  alias Db.Clients
  alias Db.Clients.Resource
  alias Db.Accounts.User
  alias Api.Auth.Token

  @create_attrs %{
    app_name: "some app_name",
    data: %{"translations": "test"},
    hash: "some hash",
    resource_name: "some resource_name"
  }

  def fixture(:resource) do
    {:ok, resource} = Clients.create_or_update_resource(@create_attrs)
    resource
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/helio.fm.v1+json")}
  end

  describe "get client resource" do
    setup [:create_resource]

    test "renders resource when data is valid", %{conn: conn, resource: %Resource{} = resource} do
      conn = get client(conn), api_client_resource_path(conn, :get_client_resource, resource.app_name, resource.resource_name)
      assert json_response(conn, 200)["data"] == %{"translations" => "test"}
    end

    test "renders errors when app or resource does not exist", %{conn: conn, resource: resource} do
      conn = get client(conn), api_client_resource_path(conn, :get_client_resource, "1", resource.resource_name)
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  describe "update client resource" do
    test "renders error on unauthenticated request to update resource", %{conn: conn} do
      conn = post client(conn), api_client_resource_update_path(conn, :update_client_resource, "helio", "translations")
      assert response(conn, 401)
    end

    test "renders error on request to update unknown resource", %{conn: conn} do
      conn = post authenticated(conn), api_client_resource_update_path(conn, :update_client_resource, "1", "2")
      assert response(conn, 404)
    end
  end

  defp authenticated(conn) do
    user = %User{id: "11111111-1111-1111-1111-111111111111", password: "admin"}
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: %{admin: [:read, :write]})
    conn
      |> recycle
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> put_req_header("client", "helio")
  end

  defp client(conn) do
    conn
      |> recycle
      |> put_req_header("client", "helio")
  end

  defp create_resource(_) do
    resource = fixture(:resource)
    {:ok, resource: resource}
  end
end
