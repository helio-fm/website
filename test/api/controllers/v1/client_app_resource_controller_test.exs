defmodule Api.V1.ClientAppResourceControllerTest do
  use Api.ConnCase, async: false

  alias Db.Clients
  alias Db.Clients.Resource
  alias Db.Accounts.User
  alias Api.Auth.Token

  setup_all do
    Tesla.Mock.mock_global fn
      _env -> %Tesla.Env{status: 200, headers: [{"content-type", "text/csv"}],
        body: ",,\"a\",,,\nID,,en\n::locale,,en\np,,1\na::b::c,test,abc"}
    end
    :ok
  end

  @create_attrs %{
    app_name: "some app_name",
    data: %{translations: "test"},
    hash: "some hash",
    type: "some type"
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
      conn = get client(conn), api_client_resource_path(conn, :get_client_resource, resource.app_name, resource.type)
      assert json_response(conn, 200)["data"] == %{"translations" => "test"}
    end

    test "renders errors when app or resource does not exist", %{conn: conn, resource: resource} do
      conn = get client(conn), api_client_resource_path(conn, :get_client_resource, "1", resource.type)
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

    test "updates translations resource", %{conn: conn} do
      conn = post authenticated(conn), api_client_resource_update_path(conn, :update_client_resource, "helio", "translations")
      assert json_response(conn, 200)["data"] == %{"translations" => %{"locale" => [%{"id" => "en", "literal" => [%{"name" => "a::b::c", "translation" => "abc"}], "name" => "en", "pluralEquation" => "1", "pluralLiteral" => []}]}}
    end
  end

  defp authenticated(conn) do
    user = %User{id: "11111111-1111-1111-1111-111111111111"}
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
