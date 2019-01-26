defmodule Db.AccountsTest do
  use Db.DataCase

  alias Db.Accounts

  describe "users" do
    alias Db.Accounts.User

    @valid_attrs %{
      login: "helio.fm",
      email: "email@helio.fm",
      name: "john",
      github_uid: "12345"
    }

    @invalid_attrs %{login: nil, name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      stored_user = Accounts.get_user!(user.id)
      assert user.login == stored_user.login
      assert user.email == stored_user.email
      assert user.name == stored_user.name
      assert user.inserted_at == stored_user.inserted_at
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "email@helio.fm"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert nil == Accounts.get_user_by_login(user.login)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_by_login!(user.login) end
      assert nil == Accounts.get_user_by_github_uid(user.github_uid)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_by_github_uid!(user.github_uid) end
    end
  end

  describe "sessions" do
    alias Db.Accounts.Session

    @valid_attrs %{
      device_id: "device_id",
      platform_id: "some platform_id",
      token: "some token"
    }

    @invalid_attrs %{platform_id: nil, device_id: nil, token: nil}

    def session_fixture(attrs \\ %{}) do
      {:ok, session} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_or_update_session()

      session
    end

    test "get_sessions_for_user returns brief sessions info for a given user" do
      user = user_fixture()
      session = session_fixture(%{user_id: user.id})
      {:ok, sessions_brief} = Accounts.get_sessions_for_user(user.id)
      assert Enum.count(sessions_brief) == 1
      session_brief = sessions_brief |> Enum.at(0)
      assert session_brief.platform_id == session.platform_id
      assert session_brief.inserted_at != nil
      assert session_brief.updated_at != nil
    end

    test "get_user_session_for_device returns the session with given id" do
      user = user_fixture()
      session = session_fixture(%{user_id: user.id})
      {:ok, response} = Accounts.get_user_session_for_device(user.id, session.device_id)
      assert response.id == session.id
    end

    test "create_or_update_session/1 with valid data creates and updates a session" do
      assert {:ok, %Session{} = session} = Accounts.create_or_update_session(@valid_attrs)
      assert session.device_id == "device_id"
      assert session.platform_id == "some platform_id"
      assert session.token == "some token"

      conflict_attrs = Map.put(%{@valid_attrs | token: "some other token"}, :user_id, session.user_id)

      assert {:ok, %Session{} = session2} = Accounts.create_or_update_session(conflict_attrs)
      assert session2.user_id == session.user_id
      assert session2.device_id == "device_id"
      assert session2.platform_id == "some platform_id"
      assert session2.token == "some other token"
    end

    test "create_or_update_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_or_update_session(@invalid_attrs)
    end

    test "create_or_update_session/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_or_update_session(@invalid_attrs)
    end

    test "delete_session/1 deletes the session" do
      user = user_fixture()
      session = session_fixture(%{user_id: user.id})
      assert {:ok, %Session{}} = Accounts.delete_session(session)
      assert {:ok, []} == Accounts.get_sessions_for_user(user.id)
    end
  end

  describe "user_resources" do
    alias Db.Accounts.Resource

    @valid_attrs %{owner_id: nil,
      data: %{},
      type: "some type",
      name: "some name"}

    @invalid_attrs %{owner_id: nil, data: nil, type: nil, name: nil}

    def resource_fixture(attrs \\ %{}) do
      user = user_fixture()

      {:ok, resource} =
        %{owner_id: user.id}
        |> Enum.into(attrs)
        |> Enum.into(@valid_attrs)
        |> Accounts.create_resource()

      {resource, user}
    end

    test "get_resource_for_user/3 returns the resource for a given user and type/name" do
      {resource, user} = resource_fixture()
      {:ok, %Resource{} = resource2} = Accounts.get_resource_for_user(user.id, resource.type, resource.name)
      assert resource2.data == resource.data
      assert resource2.type == resource.type
      assert resource2.name == resource.name
      assert resource2.hash != nil
    end

    test "get_resource_for_user/3 returns error for non-existing name" do
      {resource, user} = resource_fixture()
      assert {:error, :resource_not_found} = Accounts.get_resource_for_user(user.id, resource.type, "invalid")
    end

    test "get_resources_brief_for_user/2 returns the resource brief for a given user and type" do
      {resource, user} = resource_fixture()
      {:ok, resources} = Accounts.get_resources_brief_for_user(user.id)
      assert Enum.count(resources) == 1
      resource2 = List.first(resources)
      assert resource2.type == resource.type
      assert resource2.name == resource.name
      assert resource2.hash != nil
      assert resource2.data == nil
    end

    test "update_resource/1 with valid data updates a resource" do
      {resource, user} = resource_fixture()
      updated_data = %{hotkeyScheme: "test"}
      conflict_attrs = %{owner_id: user.id, data: updated_data} |> Enum.into(@valid_attrs)

      assert {:ok, %Resource{} = resource2} = Accounts.update_resource(conflict_attrs)
      assert resource2.owner_id == resource.owner_id
      assert resource2.type == resource.type
      assert resource2.name == resource.name
      assert resource2.data == updated_data
      assert resource2.hash != resource.hash
      assert resource2.hash != nil
    end

    test "update_resource/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.update_resource(@invalid_attrs)
    end

    test "delete_resource/1 deletes the resource" do
      {resource, user} = resource_fixture()
      assert {:ok, %Resource{}} = Accounts.delete_resource(resource)
      assert {:error, :resource_not_found} = Accounts.get_resource_for_user(user.id, resource.type, resource.name)
    end
  end
end
