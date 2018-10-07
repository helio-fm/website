defmodule Jobs.Util.CollectBuilds do
  @moduledoc """
  A job to scan through releases directory and fill up app versions table
  """

  use GenServer
  require Logger

  alias Db.Clients

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
    Enum.map(build_files,
      fn x -> parse_and_update_version(x) end)
  end

  defp parse_and_update_version(build_file) do
    try do
      with {:ok, version_attrs} <- parse_version_attrs(build_file),
           {:ok, _version} <- Clients.create_or_update_app_version(version_attrs),
        do: {:ok, build_file}
    rescue
      _ -> {:error, build_file} # avoid DB insertion errors
    end
  end

  defp parse_version_attrs(build_file) do
    # Example of valid file names to be parsed:
    # helio-dev.exe
    # helio-dev-32-bit.zip
    # helio-2.0-64-bit.tar.gz
    # helio-20.02.232.AppImage
    groups = Regex.run(~r/(\w*)-(\d+\.?\d+\.?\d*|dev)(\.|-64-\w*\.|-32-\w*\.)(.*)/, build_file)
    if Enum.count(groups) == 5 do
      app_name = groups |> Enum.at(1)
      version_and_branch = groups |> Enum.at(2) |> parse_version_and_branch()
      arch = groups |> Enum.at(3) |> parse_architecture()
      platform_and_type = groups |> Enum.at(4) |> parse_platform_and_type()
      attrs = platform_and_type
      |> Map.merge(version_and_branch)
      |> Map.merge(arch)
      |> Map.merge(%{
        app_name: app_name,
        link: Path.join(@builds_base_url, build_file)
      })

      Logger.info inspect attrs
      {:ok, attrs}
    else
      {:error, :parse_error}
    end
  end

  defp parse_architecture(arch) do
    cond do
      String.contains?(arch, "32") -> %{architecture: "32-bit"}
      String.contains?(arch, "64") -> %{architecture: "64-bit"}
      true -> %{architecture: "all"}
    end
  end

  defp parse_version_and_branch(version) do
    if String.contains?(version, "dev") do
      %{branch: "develop", version: nil}
    else
      %{branch: "stable", version: version}
    end
  end

  # credo:disable-for-lines:10 /Refactor/
  defp parse_platform_and_type(extension) do
    case extension do
      "zip" -> %{platform_type: "Windows", build_type: "portable"}
      "exe" -> %{platform_type: "Windows", build_type: "installer"}
      "dmg" -> %{platform_type: "macOS", build_type: "disk image"}
      "pkg" -> %{platform_type: "macOS", build_type: "installer"}
      "apk" -> %{platform_type: "Android", build_type: "package"}
      "deb" -> %{platform_type: "Linux", build_type: "deb package"}
      "tar.gz" -> %{platform_type: "Linux", build_type: "tarball"}
      "AppImage" -> %{platform_type: "Linux", build_type: "AppImage"}
      _ -> %{}
    end
  end

  defp schedule_work do
    Process.send_after(self(), :process, 1000 * 60 * 30) # 30 min
  end
end
