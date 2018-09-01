defmodule Db.AccountsTest do
  use Db.DataCase

  alias Db.Accounts

  describe "users" do
    alias Db.Accounts.User

    @valid_attrs %{
      login: "helio.fm",
      email: "email@helio.fm",
      name: "john",
      password: "some password",
      github_uid: "12345"
    }

    @update_attrs %{
      login: "helio.fm",
      email: "updated-email@helio.fm",
      name: "doe",
      password: "some updated password"
    }

    @invalid_attrs %{login: nil, name: nil, password: nil}

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
      assert user.password_hash == stored_user.password_hash
      assert stored_user.password == nil
      assert stored_user.password_confirmation == nil
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "email@helio.fm"
      assert user.password_hash != ""
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "updated-email@helio.fm"
      assert user.password_hash != ""
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      stored_user = Accounts.get_user(user.id)
      assert user.login == stored_user.login
      assert user.email == stored_user.email
      assert user.name == stored_user.name
      assert user.inserted_at == stored_user.inserted_at
      assert user.password_hash == stored_user.password_hash
      assert stored_user.password == nil
      assert stored_user.password_confirmation == nil
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert nil == Accounts.get_user_by_login(user.login)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_by_login!(user.login) end
      assert nil == Accounts.get_user_by_github_uid(user.github_uid)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_by_github_uid!(user.github_uid) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
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
      {:ok, sessions_brief} = Accounts.get_sessions_for_user(user)
      assert Enum.count(sessions_brief) == 1
      session_brief = sessions_brief |> Enum.at(0)
      assert session_brief.platform_id == session.platform_id
      assert session_brief.inserted_at != nil
      assert session_brief.updated_at != nil
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Accounts.get_session!(session.id) == session
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
      session = session_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.create_or_update_session(@invalid_attrs)
      assert session == Accounts.get_session!(session.id)
    end

    test "delete_session/1 deletes the session" do
      session = session_fixture()
      assert {:ok, %Session{}} = Accounts.delete_session(session)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_session!(session.id) end
    end
  end
end
