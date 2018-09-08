defmodule Db.Accounts.Resource do
  use Ecto.Schema
  import Ecto.Changeset
  alias Db.Accounts.Resource
  @moduledoc false

  schema "user_resources" do
    field :owner_id, :binary_id
    field :type, :string
    field :name, :string
    field :hash, :string
    field :data, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Resource{} = resource, attrs) do
    resource
    |> cast(attrs, [:type, :name, :hash, :data, :owner_id])
    |> validate_required([:type, :name, :hash, :data, :owner_id])
    |> unique_constraint(:name, name: :user_resources_one_name_per_user)
    # TODO hashing automatically only by data
  end

  def hash(attrs \\ %{}) do
    Base.encode16(:erlang.md5(:erlang.term_to_binary(attrs)), case: :lower)
  end  
end
