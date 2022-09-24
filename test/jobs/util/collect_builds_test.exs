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

  @test_files_1 [
    "client-dev-32-bit.zip",
    "client-dev.exe",
    "client-1.7.6-x64.tar.gz", # archived by the next one
    "client-01.7.6-64-bit.tar.gz", # archived by the next one
    "client-2.0-64-bit.tar.gz", # archived by the next one
    "client-2.9-64-bit.tar.gz", # archived by the next one
    "client-3.0-64-bit.tar.gz", # archived by the next one
    "client-3.10-64-bit.tar.gz",
    "client-03.1-64-bit.tar.gz", # archived by the previous one
    "client-04.1.02.AppImage", # archived by the next one
    "client-04.1.03.AppImage",
    "client-dev-64-bit.deb", # replaced by the next one
    "client-dev-x64.deb",
    "client-3.0.dmg",
    "client-dev-x32.pkg",
    "client-2.1.1.apk"
  ]

  @test_files_2 [
    "client-dev-32-bit.zip"
  ]

  @test_files_3 [
    "client-dev-32-bit.zip",
    "client-20.02.232111111111.zip",
    "client.zip"
  ]

  @test_files_4 [
    "client-dev-32-bit.zip",
    "client-20.02.unknown"
  ]

  defp is_archived(x, file_name),
    do: x.is_archived && x.link |> String.ends_with?(file_name)

  defp is_active(x, file_name),
    do: !x.is_archived && x.link |> String.ends_with?(file_name)

  describe "collect builds" do
    test "collect_builds/1 creates properly parsed app versions" do
      CollectBuilds.collect_builds(@test_files_1)
      versions = AppVersion |> Repo.all
      assert Enum.count(versions) == 15

      assert nil != versions |> Enum.find(fn(x) -> is_archived x, "client-1.7.6-x64.tar.gz" end)
      assert nil != versions |> Enum.find(fn(x) -> is_archived x, "client-01.7.6-64-bit.tar.gz" end)
      assert nil != versions |> Enum.find(fn(x) -> is_archived x, "client-03.1-64-bit.tar.gz" end)
      assert nil != versions |> Enum.find(fn(x) -> is_active x, "client-3.10-64-bit.tar.gz" end)

      assert nil == versions |> Enum.find(fn(x) -> is_active x, "client-dev-64-bit.deb" end)
      assert nil != versions |> Enum.find(fn(x) -> is_active x, "client-dev-x64.deb" end)
      assert nil != versions |> Enum.find(fn(x) -> is_active x, "client-dev-x32.pkg" end)

      assert nil != versions |> Enum.find(fn(x) -> is_archived x, "client-04.1.02.AppImage" end)
      assert nil != versions |> Enum.find(fn(x) -> is_active x, "client-04.1.03.AppImage" end)
    end

    test "collect_builds/1 cleans up incorrect links" do
      # insert a version with invalid link
      # and make sure it is removed after the link check:
      Clients.update_versions([%{
        app_name: "an", platform_type: "p", build_type: "bt",
        architecture: "all", branch: "dev", version: "0",
        link: @builds_base_url <> "test.app"}])

      {:ok, results} = CollectBuilds.collect_builds(@test_files_2)
      assert %AppVersion{} = List.first(results)

      versions = AppVersion |> Repo.all
      assert Enum.count(versions) == 1
    end

    test "collect_builds/1 rolls back the transaction when one filename causes DB to throw" do
      CollectBuilds.collect_builds(@test_files_3)
      versions = AppVersion |> Repo.all
      assert Enum.empty?(versions)
    end

    test "collect_builds/1 skips invalid file names and inserts valid ones" do
      CollectBuilds.collect_builds(@test_files_4)
      versions = AppVersion |> Repo.all
      assert Enum.count(versions) == 1
    end
  end
end
