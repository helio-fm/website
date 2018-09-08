defmodule Api.ClientAppResourceController do
  use Api, :controller
  @moduledoc false

  alias Db.Clients
  alias Db.Clients.Resource

  action_fallback Api.FallbackController

  def get_client_resource(conn, %{"app" => app_name, "resource" => resource_type}) do
    with {:ok, %Resource{} = resource} <- Clients.get_resource_for_app(app_name, resource_type),
      do: render(conn, "resource.data.v1.json", resource: resource)
  end

  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:write]}] when action in [:update_client_resource]

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
