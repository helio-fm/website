defmodule Jobs.Util.CollectBuildsTest do
  use Jobs.DataCase

  alias Jobs.Util.CollectBuilds
  alias Db.Clients.AppVersion

  @test_files [
    "client-dev.exe",
    "client-dev-32-bit.zip",
    "client-2.0-64-bit.tar.gz",
    "client-02.1.02.AppImage",
    "client-dev.deb",
    "client-3.0.dmg",
    "client-dev-32-bit.pkg",
    "client-2.1.1.apk",
    "client-20.02.232111111111.zip",
    "client.zip",
    "client-20.02.unknown"
  ]

  describe "collect builds" do
    test "collect_builds/1 creates properly parsed app versions" do
      results = CollectBuilds.collect_builds(@test_files)
      assert {:error, _} = List.last(results)
      assert {:ok, _} = List.first(results)

      versions = AppVersion |> Repo.all
      assert Enum.count(versions) == 8
      version = List.first(versions)
      assert version.app_name == "client"
      assert version.platform_type == "Windows"
      assert version.build_type == "installer"
      assert version.branch == "develop"
      assert version.architecture == "all"
      assert version.version == nil
      assert version.link != nil
    end
  end
end
