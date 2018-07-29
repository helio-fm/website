defmodule Musehackers.Clients do
  @moduledoc """
  The Clients context.
  """

  import Ecto.Query, warn: false
  alias Musehackers.Repo

  alias Musehackers.Clients.Resource

  @doc """
  Gets a single resource for a client.

  ## Examples

      iex> get_resource_for_app("helio", "translations")
      %Resource{}

      iex> get_resource_for_app("helio", "test")
      {:error, :resource_not_found}

  """

  def get_resource_for_app(app_name, resource_name) do
    query = from r in Resource,
      where: r.app_name == ^app_name and r.resource_name == ^resource_name,
      select: struct(r, [:data, :resource_name])
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
    on_conflict = [set: [data: attrs.data, hash: attrs.hash]]
    conflict_target = [:app_name, :resource_name]
    %Resource{}
    |> Resource.changeset(attrs)
    |> Repo.insert(on_conflict: on_conflict, conflict_target: conflict_target)
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

  alias Musehackers.Clients.App

  @doc """
  Returns the list of apps.

  ## Examples

      iex> list_apps()
      [%App{}, ...]

  """
  def list_apps do
    Repo.all(App)
  end

  @doc """
  Gets a list of client versions.

  ## Examples

      iex> get_clients_by_name("helio")
      %App{}

      iex> get_clients_by_name("test")
      {:error, :client_not_found}

  """
  def get_clients_by_name(name) do
    query = from a in App,
          where: a.app_name == ^name,
          select: struct(a, [:platform_id, :version, :link])
    case Repo.all(query) do
      [] -> {:error, :client_not_found}
      apps -> {:ok, apps}
    end
  end

  def get_clients_resources_info(name) do
    query = from r in Resource,
      where: r.app_name == ^name,
      select: struct(r, [:hash, :resource_name])
    {:ok, Repo.all(query)}
  end

  @doc """
  Creates or updates existing app version.

  ## Examples

      iex> create_or_update_app(%{field: value})
      {:ok, %App{}}

      iex> create_or_update_app(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_or_update_app(attrs \\ %{}) do
    app = %App{}
    changeset = App.changeset(app, attrs)
    link = Map.get(attrs, "link")
    version = Map.get(attrs, "version")
    on_conflict = [set: [link: link, version: version]]
    conflict_target = [:app_name, :platform_id]
    Repo.insert(changeset, on_conflict: on_conflict, conflict_target: conflict_target)
  end


  @doc """
  Deletes a App.

  ## Examples

      iex> delete_app(app)
      {:ok, %App{}}

      iex> delete_app(app)
      {:error, %Ecto.Changeset{}}

  """
  def delete_app(%App{} = app) do
    Repo.delete(app)
  end

  alias Musehackers.Clients.AuthSession

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
