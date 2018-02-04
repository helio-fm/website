defmodule Musehackers.Clients.App do
  use Ecto.Schema
  import Ecto.Changeset
  alias Musehackers.Clients.App
  @moduledoc false

  schema "apps" do
    field :app_name, :string
    field :link, :string
    field :platform_id, :string
    field :version, :string

    timestamps()
  end

  @doc false
  def changeset(%App{} = app, attrs) do
    app
    |> cast(attrs, [:app_name, :platform_id, :version, :link])
    |> validate_required([:app_name, :platform_id, :version, :link])
    |> unique_constraint(:app_name)
  end
end
