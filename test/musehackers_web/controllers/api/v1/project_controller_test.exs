defmodule MusehackersWeb.Api.V1.ProjectControllerTest do
  use MusehackersWeb.ConnCase

  alias Musehackers.Accounts
  alias Musehackers.Auth.Token
  alias Musehackers.VersionControl
  alias Musehackers.VersionControl.Project

  @id "some id"

  @create_attrs %{
    id: "some id",
    alias: "some-alias",
    title: "some title",
    author_id: "11111111-1111-1111-1111-111111111111"
  }

  # @update_attrs %{
  #   alias: "some updated alias",
  #   title: "some updated title",
  #   author_id: "11111111-1111-1111-1111-111111111111"
  # }
  
  @invalid_attrs %{alias: nil, id: nil, title: nil}

  describe "create project" do
    setup [:create_user]

    test "renders project when data is valid", %{conn: conn, user: user} do
      conn = put authenticated(conn, user), api_v1_vcs_project_path(conn, :create_or_update, @id), project: @create_attrs
      assert %{"id" => id} = json_response(conn, :ok)["data"]
      assert json_response(conn, :ok)["data"] == %{
        "id" => @id,
        "alias" => "some-alias",
        "head" => nil,
        "title" => "some title"}

      conn = get authenticated(conn, user), api_v1_vcs_project_path(conn, :summary, id)
      assert json_response(conn, :ok)["data"] == %{
        "id" => @id,
        "alias" => "some-alias",
        "head" => nil,
        "title" => "some title"}
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put authenticated(conn, user), api_v1_vcs_project_path(conn, :create_or_update, @id), project: @invalid_attrs
      assert json_response(conn, :unprocessable_entity)["errors"] != %{}
    end

    test "renders unauthorized when not authenticated", %{conn: conn, user: _} do
      conn = put conn, api_v1_vcs_project_path(conn, :create_or_update, @id), project: @create_attrs
      assert response(conn, :unauthorized)
    end
  end

  describe "get project heads" do
    setup [:create_user_and_project]

  #   test "renders project when data is valid", %{conn: conn, project: %Project{id: id} = project} do
  #     conn = put conn, api_v1_project_path(conn, :update, project), project: @update_attrs
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get conn, api_v1_project_path(conn, :show, id)
  #     assert json_response(conn, 200)["data"] == %{
  #       "id" => id,
  #       "alias" => "some updated alias",
  #       "id" => "some updated id",
  #       "title" => "some updated title"}
  #   end

    test "renders unauthorized when not authenticated", %{conn: conn, project: _, user: _} do
      conn = get conn, api_v1_vcs_project_path(conn, :heads, @id)
      assert response(conn, :unauthorized)
    end
  end

  describe "create and show project revisions" do
    setup [:create_user_and_project]

    @revision_attrs %{
      id: "some id",
      message: "some message",
      hash: "some hash",
      data: %{},
      parent_id: nil,
      project_id: nil
    }

    test "renders revision when created one with valid data", %{conn: conn, project: %Project{id: id}, user: user} do
      attrs = %{@revision_attrs | project_id: id}
      conn = put authenticated(conn, user), api_v1_vcs_revision_path(conn, :create, attrs.id), revision: attrs
      assert response(conn, :created)

      conn = get authenticated(conn, user), api_v1_vcs_revision_path(conn, :show, id)
      assert json_response(conn, :ok)["data"] == %{
        "id" => "some id",
        "message" => "some message",
        "hash" => "some hash",
        "data" => %{},
        "parentId" => nil}
    end

    test "renders error when trying to create revision with existing id", %{conn: conn, project: %Project{id: id}, user: user} do
      attrs = %{@revision_attrs | project_id: id}
      conn = put authenticated(conn, user), api_v1_vcs_revision_path(conn, :create, attrs.id), revision: attrs
      assert response(conn, :created)

      conn = put authenticated(conn, user), api_v1_vcs_revision_path(conn, :create, attrs.id), revision: attrs
      assert response(conn, :unprocessable_entity)
    end

    test "renders unauthorized when not authenticated", %{conn: conn, project: _, user: _} do
      conn = get conn, api_v1_vcs_revision_path(conn, :create, @revision_attrs.id), @revision_attrs
      assert response(conn, :unauthorized)
    end
  end

  @user_attrs %{
    login: "test",
    email: "peter.rudenko@gmail.com",
    name: "name",
    password: "some password"
  }

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    {:ok, user: user}
  end

  defp create_user_and_project(_) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    {:ok, project} = VersionControl.create_or_update_project(%{@create_attrs | author_id: user.id})
    {:ok, project: project, user: user}
  end

  defp authenticated(conn, user) do
    {:ok, permissions} = Token.get_permissions_for(user)
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: permissions)
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
