defmodule Musehackers.Clients.Resource do
  use Ecto.Schema
  import Ecto.Changeset
  alias Musehackers.Clients.Resource
  @moduledoc false

  schema "resources" do
    field :app_name, :string
    field :data, :map
    field :hash, :string
    field :resource_name, :string

    timestamps()
  end

  @doc false
  def changeset(%Resource{} = resource, attrs) do
    resource
    |> cast(attrs, [:resource_name, :app_name, :hash, :data])
    |> validate_required([:resource_name, :app_name, :hash, :data])
    |> unique_constraint(:resource_name)
    |> unique_constraint(:resource_name, name: :resources_one_resource_per_app)
  end
end
