defmodule Db.Clients.Resource do
  use Ecto.Schema
  import Ecto.Changeset
  alias Db.Clients.Resource
  @moduledoc false

  schema "app_resources" do
    field :app_name, :string
    field :type, :string
    field :hash, :string
    field :data, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Resource{} = resource, attrs) do
    resource
    |> cast(attrs, [:type, :app_name, :data])
    |> validate_required([:type, :app_name, :data])
    |> unique_constraint(:type)
    |> unique_constraint(:type, name: :app_resources_one_type_per_app)
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
