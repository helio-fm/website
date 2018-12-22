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
    |> cast(attrs, [:type, :name, :data, :owner_id])
    |> validate_required([:type, :name, :data, :owner_id])
    |> unique_constraint(:name, name: :user_resources_one_name_per_user)
    |> generate_hash_by_data
  end

  defp generate_hash_by_data(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{data: data}} ->
        put_change(changeset, :hash, hash(data))
      _ ->
        changeset
    end
  end

  def hash(attrs \\ %{}) do
    Base.encode16(:erlang.md5(:erlang.term_to_binary(attrs)), case: :lower)
  end  
end
