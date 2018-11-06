defmodule Jobs.Util.CollectBuildsTest do
  use Jobs.DataCase

  alias Db.Clients
  alias Db.Clients.AppVersion
  alias Jobs.Util.CollectBuilds

  setup do
    Tesla.Mock.mock fn
      _env -> %Tesla.Env{status: 404, headers: [], body: ""}
    end
    :ok
  end

  @builds_base_url Application.get_env(:musehackers, :builds_base_url)

  @test_files [
    "client-dev-32-bit.zip",
    "client-dev.exe",
    "client-2.0-64-bit.tar.gz",
    "client-02.1.02.AppImage",
    "client-dev.deb",
    "client-3.0.dmg",
    "client-dev-x32.pkg",
    "client-2.1.1.apk",
    "client-20.02.232111111111.zip",
    "client.zip",
    "client-20.02.unknown"
  ]

  describe "collect builds" do
    test "collect_builds/1 creates properly parsed app versions" do
      # insert some version and make sure it is removed after the link check:
      Clients.create_or_update_app_version(%{
        app_name: "an", platform_type: "p", build_type: "bt",
        architecture: "all", branch: "dev", version: "0",
        link: @builds_base_url <> "test.app"})

      results = CollectBuilds.collect_builds(@test_files)
      assert {:error, _} = List.last(results)
      assert {:ok, _} = List.first(results)

      versions = AppVersion |> Repo.all
      assert Enum.count(versions) == 8
      version = List.first(versions)
      assert version.app_name == "client"
      assert version.platform_type == "Windows"
      assert version.build_type == "portable"
      assert version.branch == "develop"
      assert version.architecture == "32-bit"
      assert version.version == nil
      assert version.link != nil
    end
  end
end
