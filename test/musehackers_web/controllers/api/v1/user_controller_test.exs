defmodule MusehackersWeb.Api.V1.UserControllerTest do
  use MusehackersWeb.ConnCase

  alias Musehackers.Auth.Token
  alias Musehackers.Accounts

  @create_attrs %{
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
      conn = get authenticated(conn, user), api_user_path(conn, :get_current_user)
      assert json_response(conn, 200)["data"]["email"] == user.email
      assert json_response(conn, 200)["data"]["login"] == user.login
      assert json_response(conn, 200)["data"]["name"] == user.name
    end

    test "renders errors when not authenticated", %{conn: conn} do
      conn = get conn, api_user_path(conn, :get_current_user)
      assert response(conn, 401) =~ "unauthenticated"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user and renders error when requested current profile for deleted user", %{conn: conn, user: user} do
      conn = delete authenticated(conn, user), api_user_path(conn, :delete, user)
      assert response(conn, 204)

      conn = get authenticated(conn, user), api_user_path(conn, :get_current_user)
      assert response(conn, 401) =~ "no_resource_found"
    end

    test "renders errors when not authenticated", %{conn: conn, user: user} do
      conn = delete conn, api_user_path(conn, :delete, user)
      assert response(conn, 401) =~ "unauthenticated"
    end
  end

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    {:ok, user: user}
  end

  defp authenticated(conn, user) do
    {:ok, permissions} = Token.get_permissions_for(user)
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: permissions)
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
