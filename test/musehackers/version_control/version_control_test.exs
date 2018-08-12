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
    alias: "some-alias",
    id: "some id",
    title: "some title",
    author_id: nil
  }

  describe "projects" do
    alias Musehackers.VersionControl.Project

    @update_attrs %{
      alias: "",
      id: "some updated id",
      title: "Тестовая симфония ;%:",
      author_id: nil
    }

    @invalid_attrs %{alias: nil, id: nil, title: nil}

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert VersionControl.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert VersionControl.get_project!(project.id) == project
    end

    test "create_or_update_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VersionControl.create_or_update_project(@invalid_attrs)
    end

    test "create_or_update_project/2 with new aliaa updates the project" do
      project = project_fixture()
      attrs = %{@update_attrs | author_id: project.author_id, id: project.id, alias: project.alias}
      assert {:ok, project} = VersionControl.create_or_update_project(attrs)
      assert project.alias == "some-alias"
    end

    test "create_or_update_project/2 with empty alias updates the project with generated one" do
      project = project_fixture()
      attrs = %{@update_attrs | author_id: project.author_id, id: project.id}
      assert {:ok, project} = VersionControl.create_or_update_project(attrs)
      assert project.title == "Тестовая симфония ;%:"
      assert project.alias == "testovaya-simfoniya"
    end

    test "create_or_update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = VersionControl.create_or_update_project(%{@invalid_attrs | id: project.id})
      assert project == VersionControl.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = VersionControl.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> VersionControl.get_project!(project.id) end
    end
  end

  describe "revisions" do
    alias Musehackers.VersionControl.Revision

    @valid_attrs %{
      data: %{},
      hash: "some hash",
      id: "some id",
      message: "some message",
      project_id: nil,
      parent_id: nil
    }

    @invalid_attrs %{data: nil, hash: nil, id: nil, message: nil}

    def revision_fixture(attrs \\ %{}) do
      project = project_fixture()

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

    test "create_revision/2 with valid data creates the revision" do
      project = project_fixture()
      assert {:ok, revision} = VersionControl.create_revision(%{@valid_attrs | project_id: project.id})
      assert %Revision{} = revision
      assert revision.data == %{}
      assert revision.hash == "some hash"
      assert revision.id == "some id"
      assert revision.message == "some message"
    end

    test "create_revision/2 fails when clasing with existing revision" do
      revision = revision_fixture()
      VersionControl.create_revision(%{@valid_attrs | project_id: revision.project_id, message: "new"})
      assert revision == VersionControl.get_revision!(revision.id)
      assert revision.message == "some message"
    end

    test "delete_revision/1 deletes the revision" do
      revision = revision_fixture()
      assert {:ok, %Revision{}} = VersionControl.delete_revision(revision)
      assert_raise Ecto.NoResultsError, fn -> VersionControl.get_revision!(revision.id) end
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
      |> VersionControl.create_or_update_project()

    project
  end
end
