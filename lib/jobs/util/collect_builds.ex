defmodule Jobs.Util.CollectBuilds do
  @moduledoc """
  A job to scan through releases directory and fill up app versions table
  """

  use Tesla
  use GenServer

  require Logger

  alias Db.Repo
  alias Db.Clients
  alias Db.Clients.AppVersion

  plug Tesla.Middleware.FollowRedirects, max_redirects: 2

  @builds_path Application.get_env(:musehackers, :builds_path)
  @builds_base_url Application.get_env(:musehackers, :builds_base_url)

  defp get_build_files() do
    @builds_path |> Path.join("**") |> Path.wildcard() |> Enum.map(&Path.basename/1)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    try do
      Logger.info IO.ANSI.magenta <> "Starting Helio builds collector job as " <> to_string(__MODULE__) <> IO.ANSI.reset
      collect_builds(get_build_files())
      schedule_work()
      {:ok, nil}
    rescue
      exception -> Logger.error inspect exception
      :ignore
    end
  end

  def handle_info(:process, state) do
    collect_builds(get_build_files())
    schedule_work()
    {:noreply, state}
  end

  def collect_builds(build_files) do
    # Cleanup all records where link contains hostname, but download responds with 404:
    invalid_versions = AppVersion |> Repo.all |> Enum.filter(fn x -> link_is_invalid(x.link) end)
    for app_version <- invalid_versions, do: Clients.delete_app_version(app_version)
    # Find all available versions and feed it to Clients.update_versions,
    # which will mark the outdated versions:
    version_attributes = Enum.map(build_files, fn x -> parse_version_attrs(x) end)

    try do
      Clients.update_versions(version_attributes)
    rescue
      _ -> {:error, nil} # catch DB insertion errors
    end
  end

  defp link_is_invalid(link) do
    needs_head_check = String.downcase(link) =~ @builds_base_url
    needs_head_check && link |> Tesla.head |> head_not_found
  end

  defp head_not_found({:ok, %Tesla.Env{status: 404}}), do: true
  defp head_not_found(_), do: false

  defp parse_version_attrs(file) do
    # Example of valid file names to be parsed:
    # helio-dev.exe
    # helio-develop-32-bit.zip
    # helio-2.0-x64.tar.gz
    # helio-20.02.232.AppImage
    groups = Regex.run(~r/(\w*)-(\d+\.?\d+\.?\d*|dev\w*)-?(|x64|x32|64-bit|32-bit|i386|x86_64)\.(.*)/, file)
    if groups != nil && Enum.count(groups) == 5 do
      app_name = groups |> Enum.at(1)
      version_and_branch = groups |> Enum.at(2) |> parse_version_and_branch()
      arch = groups |> Enum.at(3) |> parse_architecture()
      platform_and_type = groups |> Enum.at(4) |> parse_platform_and_type()
      file_stat = get_file_stat(file)

      attrs = platform_and_type
      |> Map.merge(version_and_branch)
      |> Map.merge(arch)
      |> Map.merge(%{
        app_name: app_name,
        link: Path.join(@builds_base_url, file),
        file_size: file_stat.size,
        file_date: DateTime.from_unix!(file_stat.mtime)
      })
      attrs
    else
      nil
    end
  end

  def get_file_stat(file) do
    file_path = Path.join(@builds_path, file)
    try do
      File.stat!(file_path, time: :posix)
    rescue
      _ -> %{size: 0, mtime: 0}
    end
  end

  defp parse_architecture(arch) when arch in ["x32", "32-bit", "i386"],
    do: %{architecture: "32-bit"}

  defp parse_architecture(arch) when arch in ["x64", "64-bit", "x86_64"],
    do: %{architecture: "64-bit"}

  defp parse_architecture(_),
    do: %{architecture: "all"}

  defp parse_version_and_branch(version) when version in ["dev", "develop"],
    do: %{branch: "develop", version: "develop"}

  defp parse_version_and_branch(version),
    do: %{branch: "stable", version: version}

  defp parse_platform_and_type(ext) when ext === "zip",
    do: %{platform_type: "Windows", build_type: "portable"}

  defp parse_platform_and_type(ext) when ext === "exe",
    do: %{platform_type: "Windows", build_type: "installer"}

  defp parse_platform_and_type(ext) when ext === "dll",
    do: %{platform_type: "Windows", build_type: "VST3 plugin"}

  defp parse_platform_and_type(ext) when ext === "vst3",
    do: %{platform_type: "Windows", build_type: "VST3 plugin"}

  defp parse_platform_and_type(ext) when ext === "dmg",
    do: %{platform_type: "macOS", build_type: "disk image"}

  defp parse_platform_and_type(ext) when ext === "pkg",
    do: %{platform_type: "macOS", build_type: "installer"}

  defp parse_platform_and_type(ext) when ext === "apk",
    do: %{platform_type: "Android", build_type: "package"}

  defp parse_platform_and_type(ext) when ext === "deb",
    do: %{platform_type: "Linux", build_type: "deb package"}

  defp parse_platform_and_type(ext) when ext === "tar.gz",
    do: %{platform_type: "Linux", build_type: "tarball"}

  defp parse_platform_and_type(ext) when ext === "AppImage",
    do: %{platform_type: "Linux", build_type: "AppImage"}

  defp parse_platform_and_type(ext) when ext === "so",
    do: %{platform_type: "Linux", build_type: "VST3 plugin"}

  defp parse_platform_and_type(_), do: %{}

  defp schedule_work do
    Process.send_after(self(), :process, 1000 * 60 * 60 * 6) # 6h
  end
end
