defmodule MusehackersWeb.Api.V1.ClientResourceControllerTest do
  use MusehackersWeb.ConnCase

  alias Musehackers.Clients
  alias Musehackers.Clients.Resource
  alias Musehackers.Accounts.User
  alias Musehackers.Auth.Token

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
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "get client resource" do
    setup [:create_resource]

    test "renders resource when data is valid", %{conn: conn, resource: %Resource{} = resource} do
      conn = get authenticated(conn), api_v1_client_resource_path(conn, :get_client_resource, resource.app_name, resource.resource_name)
      assert json_response(conn, 200)["data"] == %{"translations" => "test"}
    end

    test "renders errors when app or resource does not exist", %{conn: conn, resource: _resource} do
      conn = get authenticated(conn), api_v1_client_resource_path(conn, :get_client_resource, "1", "2")
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  defp authenticated(conn) do
    user = %User{id: "11111111-1111-1111-1111-111111111111", password: "admin"}
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: %{admin: [:read, :write]})
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end

  defp create_resource(_) do
    resource = fixture(:resource)
    {:ok, resource: resource}
  end
end
