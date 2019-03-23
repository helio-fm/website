defmodule Db.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Db.Repo

  alias Db.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user(id), do: Repo.get(User, id)
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_login(login), do: Repo.get_by(User, login: login)
  def get_user_by_login!(login), do: Repo.get_by!(User, login: login)

  def get_user_by_github_uid(uid), do: Repo.get_by(User, github_uid: uid)
  def get_user_by_github_uid!(uid), do: Repo.get_by!(User, github_uid: uid)

  @doc """
  Creates a user. Needed for tests.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Creates a user using registration attributes.
  """
  def register_user_from_github(attrs \\ %{}) do
    %User{}
    |> User.github_registration_changeset(attrs)
    |> Repo.insert()
  end


  alias Db.Accounts.Session

  @doc """
  Returns the list of sessions info for a given user.
  Tokens are not included.
  """
  def get_sessions_for_user(user_id) do
    query = from s in Session,
      where: s.user_id == ^user_id,
      select: struct(s, [:platform_id, :device_id, :inserted_at, :updated_at])
    {:ok, Repo.all(query)}
  end

  @doc """
  Returns the list of sessions info for a given user.
  Tokens are not included.
  """
  def get_recent_tokens(age_seconds) do
    date = DateTime.from_unix!(DateTime.to_unix(DateTime.utc_now()) - age_seconds)
    query = from s in Session,
      where: s.updated_at >= ^date,
      select: s
    {:ok, Repo.all(query)}
  end

  @doc """
  Gets a single session id for a given user and device.
  """
  def get_user_session_for_device(user_id, device_id) do
    query = from s in Session,
      where: s.user_id == ^user_id and s.device_id == ^device_id,
      select: struct(s, [:id])
    case Repo.one(query) do
      nil -> {:error, :session_not_found}
      session -> {:ok, session}
    end
  end

  @doc """
  Creates or updates a session.

  ## Examples

      iex> create_session(%{field: value})
      {:ok, %Session{}}

      iex> create_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_or_update_session(attrs \\ %{}) do
    on_conflict = [set: [platform_id: attrs.platform_id, token: attrs.token]]
    # This equals `ON CONFLICT ON CONSTRAINT one_session_per_device_index`:
    # conflict_target = {:constraint, :sessions_one_session_per_device}
    # But unfortunately there'll be no such constraint with that name, only unique index,
    # so we have to specify the fields (in the same way as in the index):
    conflict_target = [:user_id, :device_id]
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert(on_conflict: on_conflict, conflict_target: conflict_target)
  end

  @doc """
  Deletes a Session.

  ## Examples

      iex> delete_session(session)
      {:ok, %Session{}}

      iex> delete_session(session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end


  alias Db.Accounts.Resource

  @doc """
  Gets all resources of a given type for a user, data is not included.
  """

  def get_resources_brief_for_user(user_id) do
    query = from r in Resource,
      where: r.owner_id == ^user_id,
      select: struct(r, [:type, :name, :hash, :updated_at]),
      order_by: [:type, :name]
    {:ok, Repo.all(query)}
  end

  @doc """
  Gets full info of a single resource for a given user.
  """

  def get_resource_for_user(user_id, resource_type, resource_name) do
    query = from r in Resource,
      where: r.owner_id == ^user_id and r.type == ^resource_type and r.name == ^resource_name,
      select: r
    case Repo.one(query) do
      nil -> {:error, :resource_not_found}
      resource -> {:ok, resource}
    end
  end

  @doc """
  Updates a resource.
  """
  def update_resource(attrs \\ %{}) do
    changeset = Resource.changeset(%Resource{}, attrs)
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{data: data, hash: hash}} ->
        Repo.insert(changeset,
          on_conflict: [set: [data: data, hash: hash]],
          conflict_target: [:owner_id, :type, :name])
      _ ->
        {:error, changeset}
    end
  end

  def create_resource(attrs \\ %{}) do
    %Resource{}
    |> Resource.changeset(attrs)
    |> Repo.insert()
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
end
