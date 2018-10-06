defmodule Db.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Db.Repo
  alias Db.Accounts.User
  alias Db.Accounts.Session
  @moduledoc """
  The User model.
  """

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :login, :string
    field :email, :string
    field :name, :string

    field :password, :string, virtual: true # virtual - i.e. not stored in db
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    field :avatar, :string
    field :location, :string
    field :github_uid, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:login, :email, :name, :avatar, :location, :github_uid, :password])
    |> validate_required([:login, :email, :password])
    |> validate_changeset()
    |> validate_constraints()
  end

  @doc false
  def identity_registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:login, :email, :name, :avatar, :location, :password, :password_confirmation])
    |> validate_required([:login, :email, :password, :password_confirmation])
    |> validate_confirmation(:password)
    |> validate_changeset()
    |> validate_constraints()
  end

  @doc false
  def github_registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:github_uid, :login, :email, :avatar, :location, :name])
    |> validate_required([:github_uid, :login, :email])
    |> validate_constraints()
    |> put_change(:password_hash, "")
  end

  defp validate_changeset(user) do
    user
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:login, min: 3, max: 16)
    |> validate_format(:login, ~r/^[a-zA-Z][a-zA-Z0-9]*[.-]?[a-zA-Z0-9]+$/,
      [message: "only letters and numbers allowed, should start with a letter, only one char of (.-) allowed"])
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/^(?=.*[a-zA-Z]).*/,
      [message: "must include at least one letter"])
    |> generate_password_hash
  end

  defp validate_constraints(user) do
    user
    |> unique_constraint(:login)
    |> unique_constraint(:email)
  end

  defp generate_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Pbkdf2.hashpwsalt(password))
      _ ->
        changeset
    end
  end

  def find_and_confirm_password(email, password) do
    case Repo.get_by(User, email: String.downcase(email)) do
      nil ->
        {:error, :login_not_found}
      user ->
        if user.password_hash != "" && Comeonin.Pbkdf2.checkpw(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :login_failed}
        end
    end
  end

  def find_user_for_session(device_id, token) do
    query = from u in User,
          join: s in Session, on: s.user_id == u.id,
          where: s.device_id == ^device_id and s.token == ^token,
          select: struct(u, [:id, :login, :email])
    case Repo.one(query) do
      nil -> {:error, :invalid_session}
      user -> {:ok, user}
    end
  end
end
