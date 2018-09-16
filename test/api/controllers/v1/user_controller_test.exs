defmodule Api.V1.UserControllerTest do
  use Api.ConnCase

  alias Api.Auth.Token
  alias Db.Accounts
  alias Db.Accounts.Session
  alias Db.VersionControl

  @user_attrs %{
    login: "test",
    email: "peter.rudenko@gmail.com",
    name: "name",
    password: "some password"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/helio.fm.v1+json")}
  end

  describe "index" do
    setup [:create_user]

    test "lists all users", %{conn: conn, user: user} do
      conn = get authenticated(conn, user), api_user_path(conn, :index)
      assert json_response(conn, 200)["data"] != []
    end
  end

  describe "show current user profile" do
    setup [:create_user]

    test "renders profile when data is valid", %{conn: conn, user: user} do
      conn = get authenticated(conn, user), api_user_profile_path(conn, :get_current_user)
      assert json_response(conn, 200)["data"]["email"] == user.email
      assert json_response(conn, 200)["data"]["login"] == user.login
      assert json_response(conn, 200)["data"]["name"] == user.name
      assert json_response(conn, 200)["data"]["projects"] == []
      assert json_response(conn, 200)["data"]["sessions"] == []
      assert json_response(conn, 200)["data"]["resources"] == []
    end

    test "renders active sessions within valid profile", %{conn: conn, user: user} do
      {:ok, _jwt} = Session.update_token_for_device(user.id, "device", "platform", "token")
      conn = get authenticated(conn, user), api_user_profile_path(conn, :get_current_user)
      assert [%{"platformId" => _, "createdAt" => _, "updatedAt" => _}] = json_response(conn, 200)["data"]["sessions"]
    end

    test "renders existing resources within valid profile", %{conn: conn, user: user} do
      resource1_attrs = %{owner_id: user.id, data: %{}, type: "script", name: "test 3"}
      resource2_attrs = %{owner_id: user.id, data: %{}, type: "arp", name: "test 1"}
      resource3_attrs = %{owner_id: user.id, data: %{}, type: "arp", name: "test 2"}
      {:ok, _resource1} = Accounts.create_or_update_resource(resource1_attrs)
      {:ok, _resource2} = Accounts.create_or_update_resource(resource2_attrs)
      {:ok, _resource3} = Accounts.create_or_update_resource(resource3_attrs)
      conn = get authenticated(conn, user), api_user_profile_path(conn, :get_current_user)
      assert [%{"type" => "arp", "name" => "test 1", "hash" => _, "updatedAt" => _},
        %{"type" => "arp", "name" => "test 2", "hash" => _, "updatedAt" => _},
        %{"type" => "script", "name" => "test 3", "hash" => _, "updatedAt" => _}] = json_response(conn, 200)["data"]["resources"]
    end

    test "renders existing projects within valid profile", %{conn: conn, user: user} do
      project_attrs = %{author_id: user.id, id: "some-id", alias: "some-alias", title: "some-title"}
      {:ok, _project} = VersionControl.create_or_update_project(project_attrs)
      conn = get authenticated(conn, user), api_user_profile_path(conn, :get_current_user)
      assert [%{"id" => "some-id",
        "title" => "some-title",
        "alias" => "some-alias",
        "head" => nil,
        "updatedAt" => _}] = json_response(conn, 200)["data"]["projects"]
    end

    test "renders errors when not authenticated", %{conn: conn} do
      conn = get conn, api_user_profile_path(conn, :get_current_user)
      assert response(conn, 401) =~ "unauthenticated"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user and renders error when requested current profile for deleted user", %{conn: conn, user: user} do
      conn = delete authenticated(conn, user), api_user_path(conn, :delete, user)
      assert response(conn, 204)

      conn = get authenticated(conn, user), api_user_profile_path(conn, :get_current_user)
      assert response(conn, 401) =~ "no_resource_found"
    end

    test "renders errors when not authenticated", %{conn: conn, user: user} do
      conn = delete conn, api_user_path(conn, :delete, user)
      assert response(conn, 401) =~ "unauthenticated"
    end
  end

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    {:ok, user: user}
  end

  defp authenticated(conn, user) do
    {:ok, permissions} = Token.get_permissions_for(user)
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: permissions)
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
