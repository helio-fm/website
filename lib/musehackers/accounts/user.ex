defmodule Musehackers.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Musehackers.Repo
  alias Musehackers.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :email, :string
    field :name, :string
    field :phone, :string
    field :password, :string, virtual: true # virtual - i.e. not stored in db
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :is_admin, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :name, :phone, :password, :is_admin])
    |> validate_required([:email, :name, :password])
    |> validate_changeset
  end

  def registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :name, :phone, :password, :password_confirmation])
    |> validate_required([:email, :name, :phone, :password, :password_confirmation])
    |> validate_confirmation(:password)
    |> validate_changeset
  end

  defp validate_changeset(user) do
    user
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/^(?=.*[a-z]).*/, [message: "Must include at least one lowercase letter"])
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
    case Repo.get_by(User, email: email) do
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
