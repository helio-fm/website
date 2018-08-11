defmodule Musehackers.VersionControlTest do
  use Musehackers.DataCase

  alias Musehackers.Accounts
  alias Musehackers.VersionControl

  @user_attrs %{
    login: "helio.fm",
    email: "email@helio.fm",
    name: "john",
    password: "some password"
  }

  @project_attrs %{
    alias: "some alias",
    id: "some id",
    title: "some title",
    author_id: nil
  }

  describe "projects" do
    alias Musehackers.VersionControl.Project

    @update_attrs %{
      alias: "some updated alias",
      id: "some updated id",
      title: "some updated title"
    }

    @invalid_attrs %{alias: nil, id: nil, title: nil}

    def project_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@user_attrs)
        |> Accounts.create_user()

      {:ok, project} =
        attrs
        |> Enum.into(%{@project_attrs | author_id: user.id})
        |> VersionControl.create_project()

      project
    end

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert VersionControl.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert VersionControl.get_project!(project.id) == project
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VersionControl.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      assert {:ok, project} = VersionControl.update_project(project, @update_attrs)
      assert %Project{} = project
      assert project.alias == "some updated alias"
      assert project.id == "some updated id"
      assert project.title == "some updated title"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = VersionControl.update_project(project, @invalid_attrs)
      assert project == VersionControl.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = VersionControl.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> VersionControl.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = VersionControl.change_project(project)
    end
  end

  describe "revisions" do
    alias Musehackers.VersionControl.Revision

    @valid_attrs %{
      data: %{},
      hash: "some hash",
      id: "some id",
      message: "some message",
      project_id: "1"
    }

    @update_attrs %{
      data: %{},
      hash: "some updated hash",
      id: "some updated id",
      message: "some updated message",
      project_id: "2"
    }

    @invalid_attrs %{data: nil, hash: nil, id: nil, message: nil}

    def revision_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@user_attrs)
        |> Accounts.create_user()

      {:ok, project} =
        attrs
        |> Enum.into(%{@project_attrs | author_id: user.id})
        |> VersionControl.create_project()

      {:ok, revision} =
        attrs
        |> Enum.into(%{@valid_attrs | project_id: project.id})
        |> VersionControl.create_revision()

      revision
    end

    test "list_revisions/0 returns all revisions" do
      revision = revision_fixture()
      assert VersionControl.list_revisions() == [revision]
    end

    test "get_revision!/1 returns the revision with given id" do
      revision = revision_fixture()
      assert VersionControl.get_revision!(revision.id) == revision
    end

    test "create_revision/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VersionControl.create_revision(@invalid_attrs)
    end

    test "update_revision/2 with valid data updates the revision" do
      revision = revision_fixture()
      assert {:ok, revision} = VersionControl.update_revision(revision, %{@update_attrs | project_id: revision.project_id})
      assert %Revision{} = revision
      assert revision.data == %{}
      assert revision.hash == "some updated hash"
      assert revision.id == "some updated id"
      assert revision.message == "some updated message"
    end

    test "update_revision/2 fails to update project id of non-existent project" do
      revision = revision_fixture()
      assert {:error, %Ecto.Changeset{}} = VersionControl.update_revision(revision, @update_attrs)
      assert revision == VersionControl.get_revision!(revision.id)
    end

    test "update_revision/2 with invalid data returns error changeset" do
      revision = revision_fixture()
      assert {:error, %Ecto.Changeset{}} = VersionControl.update_revision(revision, @invalid_attrs)
      assert revision == VersionControl.get_revision!(revision.id)
    end

    test "delete_revision/1 deletes the revision" do
      revision = revision_fixture()
      assert {:ok, %Revision{}} = VersionControl.delete_revision(revision)
      assert_raise Ecto.NoResultsError, fn -> VersionControl.get_revision!(revision.id) end
    end

    test "change_revision/1 returns a revision changeset" do
      revision = revision_fixture()
      assert %Ecto.Changeset{} = VersionControl.change_revision(revision)
    end
  end
end
