defmodule Db.Accounts.Resource do
  use Ecto.Schema
  import Ecto.Changeset
  alias Db.Accounts.Resource
  @moduledoc false

  schema "user_resources" do
    field :resource_name, :string
    field :hash, :string
    field :data, :map
    field :owner_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Resource{} = resource, attrs) do
    resource
    |> cast(attrs, [:resource_name, :hash, :data, :owner_id])
    |> validate_required([:resource_name, :hash, :data, :owner_id])
    |> unique_constraint(:resource_name)
    |> unique_constraint(:resource_name, name: :resources_one_resource_per_user)
    # TODO hashing automatically only by data
  end

  def hash(attrs \\ %{}) do
    Base.encode16(:erlang.md5(:erlang.term_to_binary(attrs)), case: :lower)
  end  
end
