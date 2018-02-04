defmodule MusehackersWeb.Api.V1.UserControllerTest do
  use MusehackersWeb.ConnCase

  alias Musehackers.Auth.Token
  alias Musehackers.Accounts
  alias Musehackers.Accounts.User

  @create_attrs %{
    login: "test",
    email: "peter.rudenko@gmail.com",
    name: "name",
    password: "some password"
  }

  @update_attrs %{
    login: "test",
    email: "updated-email@helio.fm",
    name: "some updated name",
    password: "some updated password"
  }

  @invalid_attrs %{name: nil, password: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get authenticated(conn), api_v1_user_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user" do
    test "creates and renders user when data is valid", %{conn: conn} do
      conn = post authenticated(conn), api_v1_user_path(conn, :create), user: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get authenticated(conn), api_v1_user_path(conn, :show, id)
      assert json_response(conn, 200)["data"]["id"] == id
      assert json_response(conn, 200)["data"]["email"] == "peter.rudenko@gmail.com"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post authenticated(conn), api_v1_user_path(conn, :create), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when not authenticated", %{conn: conn} do
      conn = post conn, api_v1_user_path(conn, :create), user: @create_attrs
      assert response(conn, 401) =~ "unauthenticated"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "updates and renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put authenticated(conn, user), api_v1_user_path(conn, :update, user), user: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get authenticated(conn, user), api_v1_user_path(conn, :show, id)
      assert json_response(conn, 200)["data"]["id"] == id
      assert json_response(conn, 200)["data"]["email"] == "updated-email@helio.fm"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put authenticated(conn, user), api_v1_user_path(conn, :update, user), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when not authenticated", %{conn: conn, user: user} do
      conn = put conn, api_v1_user_path(conn, :update, user), user: @update_attrs
      assert response(conn, 401) =~ "unauthenticated"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete authenticated(conn, user), api_v1_user_path(conn, :delete, user)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get authenticated(conn), api_v1_user_path(conn, :show, user)
      end
    end

    test "renders errors when not authenticated", %{conn: conn, user: user} do
      conn = delete conn, api_v1_user_path(conn, :delete, user)
      assert response(conn, 401) =~ "unauthenticated"
    end
  end

  defp fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp authenticated(conn) do
    user = %User{id: "11111111-1111-1111-1111-111111111111", password: "admin"}
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: %{admin: [:read, :write]})
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end

  defp authenticated(conn, user) do
    {:ok, permissions} = Token.get_permissions_for(user)
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: permissions)
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
