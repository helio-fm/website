defmodule Musehackers.ClientsTest do
  use Musehackers.DataCase

  alias Musehackers.Clients

  describe "resources" do
    alias Musehackers.Clients.Resource

    @valid_attrs %{
      app_name: "some app_name",
      data: %{},
      hash: "some hash",
      resource_name: "some resource_name"
    }

    @update_attrs %{
      app_name: "some updated app_name",
      data: %{},
      hash: "some updated hash",
      resource_name: "some updated resource_name"
    }

    @invalid_attrs %{app_name: nil, data: nil, hash: nil, resource_name: nil}

    def resource_fixture(attrs \\ %{}) do
      {:ok, resource} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.create_resource()

      resource
    end

    test "list_resources/0 returns all resources" do
      resource = resource_fixture()
      assert Clients.list_resources() == [resource]
    end

    test "get_resource!/1 returns the resource with given id" do
      resource = resource_fixture()
      assert Clients.get_resource!(resource.id) == resource
    end

    test "create_resource/1 with valid data creates a resource" do
      assert {:ok, %Resource{} = resource} = Clients.create_resource(@valid_attrs)
      assert resource.app_name == "some app_name"
      assert resource.data == %{}
      assert resource.hash == "some hash"
      assert resource.resource_name == "some resource_name"
    end

    test "create_or_update_resource/1 with valid data creates and updates a resource" do
      assert {:ok, %Resource{} = resource} = Clients.create_or_update_resource(@valid_attrs)
      assert resource.app_name == "some app_name"
      assert resource.data == %{}
      assert resource.hash == "some hash"
      assert resource.resource_name == "some resource_name"

      conflict_attrs = %{@valid_attrs | hash: "some updated hash", data: %{translations: ""}}

      assert {:ok, %Resource{} = resource2} = Clients.create_or_update_resource(conflict_attrs)
      assert resource2.app_name == "some app_name"
      assert resource2.data == %{translations: ""}
      assert resource2.hash == "some updated hash"
      assert resource2.resource_name == "some resource_name"
    end

    test "create_or_update_resource/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_or_update_resource(@invalid_attrs)
    end

    test "create_resource/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_resource(@invalid_attrs)
    end

    test "update_resource/2 with valid data updates the resource" do
      resource = resource_fixture()
      assert {:ok, resource} = Clients.update_resource(resource, @update_attrs)
      assert %Resource{} = resource
      assert resource.app_name == "some updated app_name"
      assert resource.data == %{}
      assert resource.hash == "some updated hash"
      assert resource.resource_name == "some updated resource_name"
    end

    test "update_resource/2 with invalid data returns error changeset" do
      resource = resource_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_resource(resource, @invalid_attrs)
      assert resource == Clients.get_resource!(resource.id)
    end

    test "delete_resource/1 deletes the resource" do
      resource = resource_fixture()
      assert {:ok, %Resource{}} = Clients.delete_resource(resource)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_resource!(resource.id) end
    end

    test "change_resource/1 returns a resource changeset" do
      resource = resource_fixture()
      assert %Ecto.Changeset{} = Clients.change_resource(resource)
    end
  end

  describe "apps" do
    alias Musehackers.Clients.App

    @valid_attrs %{
      app_name: "some app_name",
      link: "some link",
      platform_id: "some platform_id",
      version: "some version"
    }

    @update_attrs %{
      app_name: "some updated app_name",
      link: "some updated link",
      platform_id: "some updated platform_id",
      version: "some updated version"
    }

    @invalid_attrs %{app_name: nil, link: nil, platform_id: nil, version: nil}

    def app_fixture(attrs \\ %{}) do
      {:ok, app} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.create_app()

      app
    end

    test "list_apps/0 returns all apps" do
      app = app_fixture()
      assert Clients.list_apps() == [app]
    end

    test "get_app!/1 returns the app with given id" do
      app = app_fixture()
      assert Clients.get_app!(app.id) == app
    end

    test "create_app/1 with valid data creates a app" do
      assert {:ok, %App{} = app} = Clients.create_app(@valid_attrs)
      assert app.app_name == "some app_name"
      assert app.link == "some link"
      assert app.platform_id == "some platform_id"
      assert app.version == "some version"
    end

    test "create_app/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_app(@invalid_attrs)
    end

    test "update_app/2 with valid data updates the app" do
      app = app_fixture()
      assert {:ok, app} = Clients.update_app(app, @update_attrs)
      assert %App{} = app
      assert app.app_name == "some updated app_name"
      assert app.link == "some updated link"
      assert app.platform_id == "some updated platform_id"
      assert app.version == "some updated version"
    end

    test "update_app/2 with invalid data returns error changeset" do
      app = app_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_app(app, @invalid_attrs)
      assert app == Clients.get_app!(app.id)
    end

    test "delete_app/1 deletes the app" do
      app = app_fixture()
      assert {:ok, %App{}} = Clients.delete_app(app)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_app!(app.id) end
    end

    test "change_app/1 returns a app changeset" do
      app = app_fixture()
      assert %Ecto.Changeset{} = Clients.change_app(app)
    end
  end
end
