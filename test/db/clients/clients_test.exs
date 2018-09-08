defmodule Db.ClientsTest do
  use Db.DataCase

  alias Db.Clients

  describe "resources" do
    alias Db.Clients.Resource

    @valid_attrs %{
      app_name: "some app_name",
      data: %{},
      hash: "some hash",
      type: "some type"
    }

    @invalid_attrs %{app_name: nil, data: nil, hash: nil, type: nil}

    def resource_fixture(attrs \\ %{}) do
      {:ok, resource} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.create_or_update_resource()

      resource
    end

    test "get_resource_for_app!/2 returns the resource for given app and name" do
      resource = resource_fixture()
      {:ok, %Resource{} = resource2} = Clients.get_resource_for_app(resource.app_name, resource.type)
      assert resource2.data == resource.data
      assert resource2.type == resource.type
    end

    test "get_resource_for_app!/2 returns error for invalid app" do
      resource = resource_fixture()
      assert {:error, :resource_not_found} = Clients.get_resource_for_app("invalid", resource.type)
    end

    test "create_or_update_resource/1 with valid data creates and updates a resource" do
      assert {:ok, %Resource{} = resource} = Clients.create_or_update_resource(@valid_attrs)
      assert resource.app_name == "some app_name"
      assert resource.data == %{}
      assert resource.hash == "some hash"
      assert resource.type == "some type"

      conflict_attrs = %{@valid_attrs | hash: "some updated hash", data: %{translations: ""}}

      assert {:ok, %Resource{} = resource2} = Clients.create_or_update_resource(conflict_attrs)
      assert resource2.app_name == resource.app_name
      assert resource2.type == resource.type
      assert resource2.data == %{translations: ""}
      assert resource2.hash == "some updated hash"
    end

    test "create_or_update_resource/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_or_update_resource(@invalid_attrs)
    end

    test "delete_resource/1 deletes the resource" do
      resource = resource_fixture()
      assert {:ok, %Resource{}} = Clients.delete_resource(resource)
      assert {:error, :resource_not_found} = Clients.get_resource_for_app(resource.app_name, resource.type)
    end
  end

  describe "apps" do
    alias Db.Clients.App

    @valid_attrs %{
      app_name: "some app_name",
      link: "some link",
      platform_id: "some platform_id",
      version: "some version"
    }

    @invalid_attrs %{app_name: nil, link: nil, platform_id: nil, version: nil}

    def app_fixture(attrs \\ %{}) do
      {:ok, app} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.create_or_update_app()

      app
    end

    test "list_apps/0 returns all apps" do
      app = app_fixture()
      assert Clients.list_apps() == [app]
    end

    test "get_clients_by_name!/1 returns the app with given name" do
      app = app_fixture()
      {:ok, apps} = Clients.get_clients_by_name(app.app_name)
      app2 = List.first(apps)
      assert app2.platform_id == app.platform_id
      assert app2.version == app.version
      assert app2.link == app.link
    end

    test "create_or_update_app/1 with valid data creates and updates a app" do
      assert {:ok, %App{} = app} = Clients.create_or_update_app(@valid_attrs)
      assert app.app_name == "some app_name"
      assert app.link == "some link"
      assert app.platform_id == "some platform_id"
      assert app.version == "some version"

      conflict_attrs = %{@valid_attrs | link: "some updated link", version: "some updated version"}

      assert {:ok, %App{} = app2} = Clients.create_or_update_app(conflict_attrs)
      assert app2.app_name == app.app_name
      assert app2.platform_id == app.platform_id
      assert app2.version == "some updated version"
      assert app2.link == "some updated link"
    end

    test "create_or_update_app/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_or_update_app(@invalid_attrs)
    end

    test "delete_app/1 deletes the app" do
      app = app_fixture()
      assert {:ok, %App{}} = Clients.delete_app(app)
      assert {:error, :client_not_found} = Clients.get_clients_by_name(app.app_name)
     end
  end

  describe "auth_sessions" do
    alias Db.Clients.AuthSession

    @valid_attrs %{
      provider: "provider",
      app_name: "app_name",
      app_platform: "app_platform",
      app_version: "app_version",
      device_id: "device_id",
      secret_key: "secret_key",
      token: "token"
    }

    def auth_session_fixture(attrs \\ %{}) do
      {:ok, auth_session} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.create_auth_session()

      auth_session
    end

    test "list_auth_sessions/0 returns all auth_sessions" do
      auth_session = auth_session_fixture()
      assert Clients.list_auth_sessions() == [auth_session]
    end

    test "get_auth_session!/1 returns the auth_session with given id" do
      auth_session = auth_session_fixture()
      assert Clients.get_auth_session!(auth_session.id) == auth_session
    end

    test "create_auth_session/1 with valid data creates a auth_session" do
      assert {:ok, %AuthSession{} = auth_session} = Clients.create_auth_session(@valid_attrs)
      assert auth_session.app_name == "app_name"
      assert auth_session.app_platform == "app_platform"
      assert auth_session.app_version == "app_version"
      assert auth_session.token == ""
      assert auth_session.secret_key != nil
      assert auth_session.secret_key != ""
      assert auth_session.secret_key != "secret_key"
    end

    test "create_auth_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_auth_session(@invalid_attrs)
    end

    test "update_auth_session/2 with valid data updates the auth_session" do
      auth_session = auth_session_fixture()
      assert {:ok, auth_session} = Clients.finalise_auth_session(auth_session, "token")
      assert %AuthSession{} = auth_session
      assert auth_session.app_name == "app_name"
      assert auth_session.app_platform == "app_platform"
      assert auth_session.app_version == "app_version"
      assert auth_session.secret_key != ""
      assert auth_session.token == "token"
    end

    test "delete_auth_session/1 deletes the auth_session" do
      auth_session = auth_session_fixture()
      assert {:ok, %AuthSession{}} = Clients.delete_auth_session(auth_session)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_auth_session!(auth_session.id) end
    end
  end
end
