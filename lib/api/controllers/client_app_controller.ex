defmodule Api.ClientAppController do
  use Api, :controller
  @moduledoc false

  alias Db.Clients
  alias Db.Clients.AppVersion
  alias Db.Clients.Resource
  alias Api.Auth.CheckUserAgent

  action_fallback Api.FallbackController

  def get_client_info(conn, %{"app" => app_name}) do
    with {:ok, user_agent} <- CheckUserAgent.check_against_app_name(conn, app_name),
         {:ok, platform} <- AppVersion.detect_platform(user_agent),
         {:ok, versions} <- Clients.get_app_versions(app_name, platform),
         {:ok, resources} <- Clients.get_resources_info(app_name),
      do: render(conn, "client.info.v1.json", versions: versions, resources: resources)
  end

  def get_client_resource(conn, %{"app" => app_name, "resource_type" => resource_type}) do
    with {:ok, %Resource{} = resource} <- Clients.get_resource_for_app(app_name, resource_type),
      do: render(conn, "resource.data.v1.json", resource: resource)
  end

  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:write]}] when action in [:update_app_version, :update_client_resource]

  def update_app_version(conn, %{"app" => app_params}) do
    with {:ok, %AppVersion{} = app_version} <- Clients.create_or_update_app_version(app_params) do
      conn
      |> put_status(:ok)
      # |> put_resp_header("location", api_client_app_info_path(conn, :get_client_info, app.app_name))
      |> render("version.info.v1.json", version: app_version)
    end
  end

  # for helio translations, force running a worker to fetch them
  def update_client_resource(conn, %{"app" => app_name, "resource" => resource_type})
  when app_name == "helio" and resource_type == "translations" do
    children = Supervisor.which_children(Jobs.Supervisor)
    pid = children
      |> Enum.filter(fn{name, _, _, _} -> name == Elixir.Jobs.Etl.Translations end)
      |> Enum.map(fn{_, pid, _, _} -> pid end)
      |> List.first
    with {:ok, %Resource{} = resource} <- GenServer.call(pid, :process, 1000 * 30), # 30 sec timeout
      do: render(conn, "resource.data.v1.json", resource: resource)
  end

  def update_client_resource(conn, _params),
    do: conn |> send_resp(:not_found, "") |> halt()

end
