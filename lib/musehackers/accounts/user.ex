defmodule Musehackers.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
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
    |> cast(attrs, [:email, :name, :password_hash])
    |> validate_required([:email, :name, :password_hash])
  end
end
