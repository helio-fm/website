defmodule Musehackers.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Musehackers.Repo

  alias Musehackers.Accounts.User

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
  Creates a user.

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
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
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
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Creates a user using registration attributes.
  """
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.identity_registration_changeset(attrs)
    |> Repo.insert()
  end

  def register_user_from_github(attrs \\ %{}) do
    %User{}
    |> User.github_registration_changeset(attrs)
    |> Repo.insert()
  end


  alias Musehackers.Accounts.Session

  @doc """
  Returns the list of sessions.

  ## Examples

      iex> list_sessions()
      [%Session{}, ...]

  """
  def list_sessions do
    Repo.all(Session)
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get_session!(123)
      %Session{}

      iex> get_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_session!(id), do: Repo.get!(Session, id)

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
end
