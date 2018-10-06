defmodule Db.Clients.AppVersion do
  use Ecto.Schema
  import Ecto.Changeset
  alias Db.Clients.AppVersion
  @moduledoc false

  schema "app_versions" do
    field :app_name, :string
    field :platform_type, :string
    field :build_type, :string
    field :architecture, :string
    field :branch, :string
    field :version, :string
    field :link, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%AppVersion{} = app, attrs) do
    app
    |> cast(attrs, [:app_name, :platform_type, :build_type, :architecture, :branch, :version, :link])
    |> validate_required([:app_name, :platform_type, :build_type, :architecture, :branch, :link])
    |> unique_constraint(:app_name, name: :apps_versions_constraint)
  end
end
