defmodule Api.V1.ProjectControllerTest do
  use Api.ConnCase

  alias Api.Auth.Token
  alias Db.Accounts
  alias Db.VersionControl
  alias Db.VersionControl.Project

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/helio.fm.v1+json")}
  end

  @id "some id"

  @project_attrs %{
    id: @id,
    alias: "some-alias",
    title: "some title",
    author_id: "11111111-1111-1111-1111-111111111111"
  }

  @revision_attrs %{
    id: "some id",
    message: "some message",
    hash: "some hash",
    data: %{},
    parent_id: nil,
    project_id: nil
  }

  @invalid_attrs %{alias: nil, id: nil, title: nil}

  describe "create project" do
    setup [:create_user]

    test "renders project when data is valid", %{conn: conn, user: user} do
      conn = put authenticated(conn, user), api_vcs_project_path(conn, :create_or_update, @id), project: @project_attrs
      assert %{"id" => id,
        "alias" => "some-alias",
        "title" => "some title",
        "head" => nil,
        "updatedAt" => _} = json_response(conn, :ok)["project"]

      conn = get authenticated(conn, user), api_vcs_project_path(conn, :summary, id)
      assert %{"id" => @id,
        "alias" => "some-alias",
        "title" => "some title",
        "head" => nil,
        "updatedAt" => _} = json_response(conn, :ok)["project"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put authenticated(conn, user), api_vcs_project_path(conn, :create_or_update, @id), project: @invalid_attrs
      assert json_response(conn, :unprocessable_entity)["errors"] != %{}
    end

    test "renders unauthorized when not authenticated", %{conn: conn, user: _} do
      conn = put conn, api_vcs_project_path(conn, :create_or_update, @id), project: @project_attrs
      assert response(conn, :unauthorized)
    end
  end

  describe "list user's projects" do
    setup [:create_user]

    test "renders all projects for a given user", %{conn: conn, user: user} do
      project1 = @project_attrs
      conn = put authenticated(conn, user), api_vcs_project_path(conn, :create_or_update, project1.id), project: project1
      assert %{"id" => _} = json_response(conn, :ok)["project"]

      project2 = %{@project_attrs | id: "another id", alias: "another-alias"}
      conn = put authenticated(conn, user), api_vcs_project_path(conn, :create_or_update, project2.id), project: project2
      assert %{"id" => _} = json_response(conn, :ok)["project"]

      conn = get authenticated(conn, user), api_vcs_project_path(conn, :index)
      assert [%{"id" => _}, %{"id" => _}] = json_response(conn, :ok)["projects"]
    end

    test "renders empty list when no projects available", %{conn: conn, user: user} do
      conn = get authenticated(conn, user), api_vcs_project_path(conn, :index)
      assert [] = json_response(conn, :ok)["projects"]
    end

    test "renders unauthorized when not authenticated", %{conn: conn, user: _} do
      conn = get conn, api_vcs_project_path(conn, :index)
      assert response(conn, :unauthorized)
    end
  end

  describe "get project heads" do
    setup [:create_revisions_tree]

    test "renders head list when data is valid", %{conn: conn, project: %Project{id: id}, user: user, tree: _} do
      conn = get authenticated(conn, user), api_vcs_project_path(conn, :heads, id)
      assert json_response(conn, 200)["revisions"] == [%{
        "id" => "5",
        "hash" => "some hash",
        "message" => "some message",
        "parentId" => "3"}, %{
        "id" => "4",
        "hash" => "some hash",
        "message" => "some message",
        "parentId" => "3"}, %{
        "id" => "2",
        "hash" => "some hash",
        "message" => "some message",
        "parentId" => "1"}]
    end

    test "renders unauthorized when not authenticated", %{conn: conn, project: _, user: _} do
      conn = get conn, api_vcs_project_path(conn, :heads, @id)
      assert response(conn, :unauthorized)
    end
  end

  describe "create and show project revisions" do
    setup [:create_user_and_project]

    test "renders revision when created one with valid data", %{conn: conn, project: %Project{id: id}, user: user} do
      attrs = %{@revision_attrs | project_id: id}
      conn = put authenticated(conn, user), api_vcs_revision_path(conn, :create, attrs.id), revision: attrs
      assert response(conn, :created)

      conn = get authenticated(conn, user), api_vcs_revision_path(conn, :show, id)
      assert json_response(conn, :ok)["revision"] == %{
        "id" => "some id",
        "message" => "some message",
        "hash" => "some hash",
        "data" => %{},
        "parentId" => nil}
    end

    test "renders error when trying to create revision with existing id", %{conn: conn, project: %Project{id: id}, user: user} do
      attrs = %{@revision_attrs | project_id: id}
      conn = put authenticated(conn, user), api_vcs_revision_path(conn, :create, attrs.id), revision: attrs
      assert response(conn, :created)

      conn = put authenticated(conn, user), api_vcs_revision_path(conn, :create, attrs.id), revision: attrs
      assert response(conn, :unprocessable_entity)
    end

    test "renders unauthorized when not authenticated", %{conn: conn, project: _, user: _} do
      conn = get conn, api_vcs_revision_path(conn, :create, @revision_attrs.id), @revision_attrs
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
    {:ok, project} = VersionControl.create_or_update_project(%{@project_attrs | author_id: user.id})
    {:ok, project: project, user: user}
  end

  defp create_revisions_tree(_) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    {:ok, project} = VersionControl.create_or_update_project(%{@project_attrs | author_id: user.id})
    {:ok, r1} = VersionControl.create_revision(%{@revision_attrs | id: "1", project_id: project.id})
    {:ok, r2} = VersionControl.create_revision(%{@revision_attrs | id: "2", project_id: project.id, parent_id: r1.id})
    {:ok, r3} = VersionControl.create_revision(%{@revision_attrs | id: "3", project_id: project.id, parent_id: r1.id})
    {:ok, r4} = VersionControl.create_revision(%{@revision_attrs | id: "4", project_id: project.id, parent_id: r3.id})
    {:ok, r5} = VersionControl.create_revision(%{@revision_attrs | id: "5", project_id: project.id, parent_id: r3.id})
    tree = [r1, r2, r3, r4, r5]
    {:ok, project: project, user: user, tree: tree}
  end

  defp authenticated(conn, user) do
    {:ok, permissions} = Token.get_permissions_for(user)
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: permissions)
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
