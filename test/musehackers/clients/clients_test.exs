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
end
