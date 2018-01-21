defmodule Musehackers.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Musehackers.Repo
  alias Musehackers.Accounts.User
  @moduledoc """
  The User model.
  """

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :login, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true # virtual - i.e. not stored in db
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :is_admin, :boolean, default: false
    # has_many :active_sessions, Musehackers.Accounts.Session

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:login, :email, :first_name, :last_name, :password, :is_admin])
    |> validate_required([:login, :email, :password])
    |> validate_changeset
  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:login, :email, :first_name, :last_name, :password, :password_confirmation])
    |> validate_required([:login, :email, :password, :password_confirmation])
    |> validate_confirmation(:password)
    |> validate_changeset
  end

  defp validate_changeset(user) do
    user
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:login)
    |> unique_constraint(:email)
    |> validate_length(:login, min: 3, max: 16)
    |> validate_format(:login, ~r/^[a-zA-Z][a-zA-Z0-9]*[.-]?[a-zA-Z0-9]+$/,
      [message: "Only letters and numbers allowed, should start with a letter, only one char of (.-) allowed"])
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/^(?=.*[a-z]).*/,
      [message: "Must include at least one lowercase letter"])
    |> generate_password_hash
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
        if Comeonin.Pbkdf2.checkpw(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :login_failed}
        end
    end
  end
end
