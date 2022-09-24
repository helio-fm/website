defmodule Db.Clients do
  @moduledoc """
  The Clients context.
  """

  import Ecto.Query, warn: false

  alias Db.Repo
  alias Db.Clients.Resource

  @doc """
  Gets a single resource for a client.

  ## Examples

      iex> get_resource_for_app("helio", "translations")
      %Resource{}

      iex> get_resource_for_app("helio", "test")
      {:error, :resource_not_found}

  """

  def get_resource_for_app(app_name, resource_type) do
    query = from r in Resource,
      where: r.app_name == ^app_name and r.type == ^resource_type,
      select: struct(r, [:data, :type])
    case Repo.one(query) do
      nil -> {:error, :resource_not_found}
      resource -> {:ok, resource}
    end
  end

  @doc """
  Creates or updates a resource.

  ## Examples

      iex> create_or_update_resource(%{field: value})
      {:ok, %Resource{}}

      iex> create_or_update_resource(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_or_update_resource(attrs \\ %{}) do
    changeset = Resource.changeset(%Resource{}, attrs)
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{data: data, hash: hash}} ->
        Repo.insert(changeset,
          on_conflict: [set: [data: data, hash: hash]],
          conflict_target: [:app_name, :type])
      _ ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a Resource.

  ## Examples

      iex> delete_resource(resource)
      {:ok, %Resource{}}

      iex> delete_resource(resource)
      {:error, %Ecto.Changeset{}}

  """
  def delete_resource(%Resource{} = resource) do
    Repo.delete(resource)
  end

  alias Db.Clients.AppVersion

  @doc """
  Returns the list of apps.

  ## Examples

      iex> list_apps()
      [%App{}, ...]

  """
  def list_apps do
    Repo.all(AppVersion)
  end

  @doc """
  Gets a list of client versions.

  to return available versions:

  select * from versions
  where app_name='helio' and platform_type ilike 'windows'
    and (string_to_array(version, '.') >= string_to_array('2.0', '.')
      or version is null);

  ## Examples

      iex> get_latest_app_versions("helio", "linux")
      %AppVersion{}

      iex> get_latest_app_versions("test", "test")
      {:error, :client_not_found}

  """
  def get_latest_app_versions(app_name, platform_type) do
    query = from a in AppVersion,
      where: a.is_archived == false
        and a.app_name == ^app_name
        and ilike(a.platform_type, ^platform_type),
      select: a,
      order_by: [:app_name, :branch, :platform_type, :architecture]
    case Repo.all(query) do
      [] -> {:error, :client_not_found}
      apps -> {:ok, apps}
    end
  end

  def get_resources_info(app_name) do
    query = from r in Resource,
      where: r.app_name == ^app_name,
      select: struct(r, [:hash, :type])
    {:ok, Repo.all(query)}
  end

  @doc """
  Creates or updates existing app version.
  Sets archived flag for all versions where a later version exists.

  ## Examples

      iex> update_versions(%{field: value})
      {:ok, %App{}}

      iex> update_versions(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_versions(versions) do
    update_query = """
      update app_versions a1
        set is_archived =
          case when
            a1.version not like 'dev%'
            and exists
            (
              select 1 from app_versions a2
                where a1.app_name = a2.app_name
                  and a1.platform_type = a2.platform_type
                  and a1.build_type = a2.build_type
                  and a1.branch = a2.branch
                  and a2.version not like 'dev%'
                  and string_to_array(a1.version, '.')::int[]
                    < string_to_array(a2.version, '.')::int[]
            )
          then true else false end;
    """

    Repo.transaction fn ->
      # If some version records are malformed
      # and fail to insert - that's fine, fuck them
      apps = Enum.map versions, fn version_attrs ->
        update_and_return_version version_attrs
      end

      # But if updating `is_archived` flags fails,
      # we'd better rollback the transaction to make sure
      # we won't get inconsistent data for app versions
      case Ecto.Adapters.SQL.query(Repo, update_query) do
        {:ok, _} ->
          apps
        {:error, error_key} ->
          Repo.rollback(error_key)
      end
    end
  end

  defp update_and_return_version(version_attrs) do
    app = %AppVersion{}
    changeset = AppVersion.changeset(app, version_attrs)
    link = Map.get(changeset.changes, :link)
    file_size = Map.get(changeset.changes, :file_size)
    file_date = Map.get(changeset.changes, :file_date)
    conflict_target = [:app_name,
      :platform_type, :build_type,
      :branch, :architecture, :version]

    case Repo.insert(changeset,
      on_conflict: [set: [link: link, file_size: file_size, file_date: file_date]],
      conflict_target: conflict_target) do
        {:ok, version} -> version
        {:error, _} -> nil
    end
  end


  @doc """
  Deletes a app version.

  ## Examples

      iex> delete_app_version(app)
      {:ok, %AppVersion{}}

      iex> delete_app_version(app)
      {:error, %Ecto.Changeset{}}

  """
  def delete_app_version(%AppVersion{} = app) do
    Repo.delete(app)
  end

  alias Db.Clients.AuthSession

  @doc """
  Returns the list of auth_sessions.

  ## Examples

      iex> list_auth_sessions()
      [%AuthSession{}, ...]

  """
  def list_auth_sessions do
    Repo.all(AuthSession)
  end

  @doc """
  Gets a single auth_session.

  Raises `Ecto.NoResultsError` if the Auth session does not exist.

  ## Examples

      iex> get_auth_session!(123)
      %AuthSession{}

      iex> get_auth_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_auth_session!(id), do: Repo.get!(AuthSession, id)

  @doc """
  Creates an auth_session.

  ## Examples

      iex> create_or_update_auth_session(%{field: value})
      {:ok, %AuthSession{}}

  """
  def create_auth_session(attrs \\ %{}) do
    %AuthSession{}
    |> AuthSession.create_changeset(attrs)
    |> Repo.insert()
  end


  @doc """
  Updates a auth_session.

  ## Examples

      iex> update_auth_session(auth_session, %{field: new_value})
      {:ok, %AuthSession{}}

      iex> update_auth_session(auth_session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def finalise_auth_session(%AuthSession{} = auth_session, token) do
    auth_session
    |> Ecto.Changeset.change(%{token: token})
    |> Repo.update()
  end

  @doc """
  Deletes a AuthSession.

  ## Examples

      iex> delete_auth_session(auth_session)
      {:ok, %AuthSession{}}

      iex> delete_auth_session(auth_session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_auth_session(%AuthSession{} = auth_session) do
    Repo.delete(auth_session)
  end

  def delete_auth_session(provider, device_id) do
    if provider != nil && device_id != nil do
      query = from(s in AuthSession, where: s.provider == ^provider and s.device_id == ^device_id)
      Repo.delete_all(query)
    end
  end

end
