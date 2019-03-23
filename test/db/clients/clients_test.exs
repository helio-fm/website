defmodule Db.ClientsTest do
  use Db.DataCase

  alias Db.Clients

  describe "resources" do
    alias Db.Clients.Resource

    @valid_attrs %{
      app_name: "some app_name",
      data: %{},
      type: "some type"
    }

    @invalid_attrs %{app_name: nil, data: nil, type: nil}

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
      assert resource.type == "some type"
      assert resource.hash != nil

      conflict_attrs = %{@valid_attrs | data: %{translations: ""}}

      assert {:ok, %Resource{} = resource2} = Clients.create_or_update_resource(conflict_attrs)
      assert resource2.app_name == resource.app_name
      assert resource2.type == resource.type
      assert resource2.data == %{translations: ""}
      assert resource2.hash != resource.hash
      assert resource2.hash != nil
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
    alias Db.Clients.AppVersion

    @valid_attrs [%{
      app_name: "some app_name",
      platform_type: "platform_type",
      build_type: "portable",
      branch: "stable",
      architecture: "all",
      version: "2.0",
      link: "some link",
      is_archived: false
    }]

    @updated_attrs [%{
      app_name: "some app_name",
      platform_type: "platform_type",
      build_type: "portable",
      branch: "stable",
      architecture: "all",
      version: "2.0",
      link: "some updated link"
    }]

    @invalid_attrs [%{app_name: nil, link: nil, platform_type: nil, version: nil}]

    def apps_fixture(attrs \\ %{}) do
      {:ok, apps} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.update_versions()

      apps
    end

    test "list_apps/0 returns all apps" do
      [app] = apps_fixture()
      assert Clients.list_apps() == [app]
    end

    test "get_latest_app_versions/2 returns the app with given name" do
      [app] = apps_fixture()
      {:ok, apps} = Clients.get_latest_app_versions(app.app_name, String.upcase(app.platform_type))
      app2 = List.first(apps)
      assert app2.platform_type == app.platform_type
      assert app2.version == app.version
      assert app2.link == app.link
    end

    test "update_versions/1 with valid data creates and updates an app" do
      assert {:ok, [%AppVersion{} = app]} = Clients.update_versions(@valid_attrs)
      assert app.app_name == "some app_name"
      assert app.link == "some link"
      assert app.platform_type == "platform_type"
      assert app.version == "2.0"

      assert {:ok, [%AppVersion{} = app2]} = Clients.update_versions(@updated_attrs)
      assert app2.app_name == app.app_name
      assert app2.platform_type == app.platform_type
      assert app2.version == "2.0"
      assert app2.link == "some updated link"
    end

    test "update_versions/1 with invalid data returns empty result" do
      assert {:ok, [nil]} = Clients.update_versions(@invalid_attrs)
    end

    test "delete_app/1 deletes the app" do
      [app] = apps_fixture()
      assert {:ok, %AppVersion{}} = Clients.delete_app_version(app)
      assert {:error, :client_not_found} = Clients.get_latest_app_versions(app.app_name, app.platform_type)
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

    @invalid_attrs %{app_name: nil, app_platform: nil, device_id: nil}

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
