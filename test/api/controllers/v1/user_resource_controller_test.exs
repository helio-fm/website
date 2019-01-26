defmodule Api.V1.UserResourceControllerTest do
  use Api.ConnCase

  alias Db.Accounts
  alias Api.Auth.Token

  @create_attrs %{
    data: %{test: "test"},
    name: "some name",
    type: "some type",
    owner_id: nil}

  @update_attrs %{
    data: %{test2: "test2"},
    name: "some name",
    type: "some type",
    owner_id: nil}

  @invalid_attrs %{data: nil, name: nil, type: nil, owner_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/helio.fm.v1+json")}
  end

  describe "create resource" do
    setup [:create_user]

    test "renders created resource when data is valid", %{conn: conn, user: user} do
      attrs = %{@create_attrs | owner_id: user.id}
      conn = put authenticated(conn, user), api_user_resource_path(conn, :create_or_update, attrs.type, attrs.name), resource: attrs
      assert %{"type" => "some type", "name" => "some name"} = json_response(conn, :ok)

      conn = get authenticated(conn, user), api_user_resource_path(conn, :show, @create_attrs.type, @create_attrs.name)
      assert %{"test" => "test"} = json_response(conn, :ok)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put authenticated(conn, user), api_user_resource_path(conn,
        :create_or_update, @create_attrs.type, @create_attrs.name), resource: @invalid_attrs
      assert json_response(conn, :unprocessable_entity)["errors"] != %{}
    end
  end

  describe "update resource" do
    setup [:create_user_and_resource]

    test "renders updated resource when data is valid", %{conn: conn, resource: _, user: user} do
      conn = put authenticated(conn, user), api_user_resource_path(conn, :create_or_update, @update_attrs.type, @update_attrs.name), resource: @update_attrs
      assert %{"type" => "some type", "name" => "some name"} = json_response(conn, :ok)

      conn = get authenticated(conn, user), api_user_resource_path(conn, :show, @create_attrs.type, @create_attrs.name)
      assert %{"test2" => "test2"} = json_response(conn, :ok)["data"]
    end

    test "renders not found when fetching existing resource as another user", %{conn: conn, resource: resource, user: _} do
      {:ok, user} = second_user_fixture()
      conn = get authenticated(conn, user), api_user_resource_path(conn, :show, resource.type, resource.name)
      assert response(conn, :not_found)
    end

    test "renders different data for different users when type and name are the same", %{conn: conn, resource: resource, user: user} do
      {:ok, user2} = second_user_fixture()
      conn = put authenticated(conn, user2), api_user_resource_path(conn, :create_or_update, resource.type, resource.name), resource: @update_attrs
      assert %{"type" => "some type", "name" => "some name"} = json_response(conn, :ok)

      conn = get authenticated(conn, user2), api_user_resource_path(conn, :show, resource.type, resource.name)
      assert %{"test2" => "test2"} = json_response(conn, :ok)["data"]

      conn = get authenticated(conn, user), api_user_resource_path(conn, :show, resource.type, resource.name)
      assert %{"test" => "test"} = json_response(conn, :ok)["data"]
    end
  end

  describe "delete resource" do
    setup [:create_user_and_resource]

    test "deletes chosen resource", %{conn: conn, resource: resource, user: user} do
      conn = delete authenticated(conn, user), api_user_resource_path(conn, :delete, resource.type, resource.name)
      assert response(conn, :no_content)

      conn = get authenticated(conn, user), api_user_resource_path(conn, :show, resource.type, resource.name)
      assert response(conn, :not_found)
    end

    test "renders unauthorized when not authenticated", %{conn: conn, resource: resource, user: _} do
      conn = get conn, api_user_resource_path(conn, :show, resource.type, resource.name)
      assert response(conn, :unauthorized)
    end

    test "renders not found when authenticated as another user", %{conn: conn, resource: resource, user: _} do
      {:ok, user} = second_user_fixture()
      conn = delete authenticated(conn, user), api_user_resource_path(conn, :delete, resource.type, resource.name)
      assert response(conn, :not_found)
    end
  end

  @user_attrs %{
    login: "test",
    email: "peter.rudenko@gmail.com",
    name: "name",
    password: "some password"
  }

  @second_user_attrs %{
    login: "second.test",
    email: "second_test@gmail.com",
    name: "name",
    password: "some password"
  }

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    {:ok, user: user}
  end

  defp create_user_and_resource(_) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    {:ok, resource} = Accounts.create_resource(%{@create_attrs | owner_id: user.id})
    {:ok, resource: resource, user: user}
  end

  defp second_user_fixture() do
    Accounts.create_user(@second_user_attrs)
  end

  defp authenticated(conn, user) do
    {:ok, permissions} = Token.get_permissions_for(user)
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: permissions)
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
