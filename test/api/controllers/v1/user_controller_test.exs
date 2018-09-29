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

  describe "show current user profile" do
    setup [:create_user]

    test "renders profile when data is valid", %{conn: conn, user: user} do
      conn = get authenticated(conn, user), api_user_profile_path(conn, :get_current_user)
      assert json_response(conn, 200)["userProfile"]["login"] == user.login
      assert json_response(conn, 200)["userProfile"]["name"] == user.name
      assert json_response(conn, 200)["userProfile"]["projects"] == []
      assert json_response(conn, 200)["userProfile"]["sessions"] == []
      assert json_response(conn, 200)["userProfile"]["resources"] == []
      assert json_response(conn, 200)["userProfile"]["email"] == nil # hide email
    end

    test "renders active sessions within valid profile", %{conn: conn, user: user} do
      {:ok, _jwt} = Session.update_token_for_device(user.id, "device", "platform", "token")
      conn = get authenticated(conn, user), api_user_profile_path(conn, :get_current_user)
      assert [%{"platformId" => _, "deviceId" => _, "createdAt" => _,
        "updatedAt" => _}] = json_response(conn, 200)["userProfile"]["sessions"]
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
        %{"type" => "script", "name" => "test 3", "hash" => _, "updatedAt" => _}] = json_response(conn, 200)["userProfile"]["resources"]
    end

    test "renders existing projects within valid profile", %{conn: conn, user: user} do
      project_attrs = %{author_id: user.id, id: "some-id", alias: "some-alias", title: "some-title"}
      {:ok, _project} = VersionControl.create_or_update_project(project_attrs)
      conn = get authenticated(conn, user), api_user_profile_path(conn, :get_current_user)
      assert [%{"id" => "some-id",
        "title" => "some-title",
        "alias" => "some-alias",
        "head" => nil,
        "updatedAt" => _}] = json_response(conn, 200)["userProfile"]["projects"]
    end

    test "renders errors when not authenticated", %{conn: conn} do
      conn = get conn, api_user_profile_path(conn, :get_current_user)
      assert response(conn, 401) =~ "unauthenticated"
    end
  end

  describe "delete active session for a user" do
    setup [:create_user]

    test "renders only existing sessions after deleting one", %{conn: conn, user: user} do
      {:ok, _jwt1} = Session.update_token_for_device(user.id, "device1", "platform", "token")
      {:ok, _jwt2} = Session.update_token_for_device(user.id, "device2", "platform", "token")

      conn = delete authenticated(conn, user), api_user_session_path(conn, :delete_user_session, "device1")
      conn = get authenticated(conn, user), api_user_profile_path(conn, :get_current_user)
      assert [%{"deviceId" => "device2"}] = json_response(conn, 200)["userProfile"]["sessions"]
    end

    test "renders errors when requested to delete unexisting session", %{conn: conn, user: user} do
      conn = delete authenticated(conn, user), api_user_session_path(conn, :delete_user_session, "device1")
      assert response(conn, 404)
    end

    test "renders errors when not authenticated", %{conn: conn} do
      conn = delete conn, api_user_session_path(conn, :delete_user_session, "device1")
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
