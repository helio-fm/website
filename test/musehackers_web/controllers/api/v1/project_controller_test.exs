defmodule MusehackersWeb.Api.V1.ProjectControllerTest do
  use MusehackersWeb.ConnCase

  alias Musehackers.Auth.Token
  alias Musehackers.Accounts

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
      assert %{"id" => id} = json_response(conn, 200)["data"]
      assert json_response(conn, 200)["data"] == %{
        "id" => @id,
        "alias" => "some-alias",
        "head" => nil,
        "title" => "some title"}

      conn = get authenticated(conn, user), api_v1_vcs_project_path(conn, :summary, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => @id,
        "alias" => "some-alias",
        "head" => nil,
        "title" => "some title"}
    end

    test "renders errors when data is invalid", %{conn: conn, user: _} do
      conn = put conn, api_v1_vcs_project_path(conn, :create_or_update, @id), project: @create_attrs
      assert response(conn, 401)
    end

    test "renders forbidden when not authenticated", %{conn: conn, user: user} do
      conn = put authenticated(conn, user), api_v1_vcs_project_path(conn, :create_or_update, @id), project: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  # describe "update project" do
  #   setup [:create_project]

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

  #   test "renders errors when data is invalid", %{conn: conn, project: project} do
  #     conn = put conn, api_v1_project_path(conn, :update, project), project: @invalid_attrs
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete project" do
  #   setup [:create_project]

  #   test "deletes chosen project", %{conn: conn, project: project} do
  #     conn = delete conn, api_v1_project_path(conn, :delete, project)
  #     assert response(conn, 204)
  #     assert_error_sent 404, fn ->
  #       get conn, api_v1_project_path(conn, :show, project)
  #     end
  #   end
  # end

  # defp create_project(_) do
  #   project = fixture(:project)
  #   {:ok, project: project}
  # end

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

  defp authenticated(conn, user) do
    {:ok, permissions} = Token.get_permissions_for(user)
    {:ok, jwt, _claims} = Token.encode_and_sign(user, %{},
      token_ttl: {1, :minute}, permissions: permissions)
    conn |> recycle |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
