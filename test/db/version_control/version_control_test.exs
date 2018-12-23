defmodule Db.VersionControlTest do
  use Db.DataCase

  alias Db.Accounts
  alias Db.VersionControl

  @user_attrs %{
    login: "helio.fm",
    email: "email@helio.fm",
    name: "john",
    password: "some password"
  }

  @project_attrs %{
    alias: "some-alias",
    id: "some id",
    title: "some title",
    author_id: nil
  }

  describe "projects" do
    alias Db.VersionControl.Project

    @update_attrs %{
      alias: "",
      id: "some updated id",
      title: "Тестовая симфония ;%:",
      author_id: nil
    }

    @invalid_attrs %{alias: nil, id: nil, title: nil}

    test "get_projects_for_user/0 returns all projects for a given user" do
      {project, user} = project_fixture()
      assert VersionControl.get_projects_for_user(user.id) == {:ok, [project]}
    end

    test "get_project/2 returns the project with given id" do
      {project, user} = project_fixture()
      assert VersionControl.get_project(project.id, user.id) == {:ok, project}
    end

    test "update_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VersionControl.update_project(@invalid_attrs)
    end

    test "update_project/2 with new aliaa updates the project" do
      {project, _user} = project_fixture()
      attrs = %{@update_attrs | author_id: project.author_id, id: project.id, alias: project.alias}
      assert {:ok, project} = VersionControl.update_project(attrs)
      assert project.alias == "some-alias"
    end

    test "update_project/2 with empty alias updates the project with generated one" do
      {project, _user} = project_fixture()
      attrs = %{@update_attrs | author_id: project.author_id, id: project.id}
      assert {:ok, project} = VersionControl.update_project(attrs)
      assert project.title == "Тестовая симфония ;%:"
      assert project.alias == "testovaya-simfoniya"
    end

    test "update_project/2 with invalid data returns error changeset" do
      {project, user} = project_fixture()
      assert {:error, %Ecto.Changeset{}} = VersionControl.update_project(%{@invalid_attrs | id: project.id})
      assert {:ok, project} == VersionControl.get_project(project.id, user.id)
      assert {:error, :project_not_found} == VersionControl.get_project(project.id, "11111111-1111-1111-1111-111111111111")
    end

    test "delete_project/1 deletes the project" do
      {project, user} = project_fixture()
      assert {:ok, %{project: %Project{}, revisions: _}} = VersionControl.delete_project(project)
      assert {:error, :project_not_found} = VersionControl.get_project(project.id, user.id)
      assert VersionControl.get_projects_for_user(user.id) == {:ok, []}
    end
  end

  describe "revisions" do
    alias Db.VersionControl.Revision

    @valid_attrs %{
      data: %{},
      timestamp: "some timestamp",
      id: "some id",
      message: "some message",
      project_id: nil,
      parent_id: nil
    }

    @invalid_attrs %{data: nil, timestamp: nil, id: nil, message: nil}

    def revision_fixture(attrs \\ %{}) do
      {project, user} = project_fixture()

      {:ok, revision} =
        attrs
        |> Enum.into(%{@valid_attrs | project_id: project.id})
        |> VersionControl.create_revision()

      {revision, user}
    end

    test "get_revision/2 returns the revision with given id" do
      {revision, user} = revision_fixture()
      assert VersionControl.get_revision(revision.id, user.id) == {:ok, revision}
    end

    test "create_revision/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VersionControl.create_revision(@invalid_attrs)
    end

    test "create_revision/2 with valid data creates the revision" do
      {project, _user} = project_fixture()
      assert {:ok, revision} = VersionControl.create_revision(%{@valid_attrs | project_id: project.id})
      assert %Revision{} = revision
      assert revision.data == %{}
      assert revision.id == "some id"
      assert revision.message == "some message"
      assert revision.timestamp == "some timestamp"
    end

    test "create_revision/2 fails when clasing with existing revision" do
      {revision, user} = revision_fixture()
      VersionControl.create_revision(%{@valid_attrs | project_id: revision.project_id, message: "new"})
      assert {:ok, revision} == VersionControl.get_revision(revision.id, user.id)
      assert revision.message == "some message"
    end

    test "delete_revision/1 deletes the revision" do
      {revision, user} = revision_fixture()
      assert {:ok, %Revision{}} = VersionControl.delete_revision(revision)
      assert {:error, :revision_not_found} = VersionControl.get_revision(revision.id, user.id)
    end
  end

  defp project_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user_attrs)
      |> Accounts.create_user()

    {:ok, project} =
      attrs
      |> Enum.into(%{@project_attrs | author_id: user.id})
      |> VersionControl.create_project()

    {project, user}
  end
end
