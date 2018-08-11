defmodule Musehackers.VersionControl.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias Musehackers.VersionControl.Project
  alias Musehackers.Accounts.User

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :binary_id

  schema "projects" do
    field :title, :string
    field :alias, :string

    belongs_to :author, User, foreign_key: :author_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Project{} = project, attrs) do
    project
    |> cast(attrs, [:id, :title, :alias, :author_id])
    |> validate_required([:id, :title, :alias])
    |> foreign_key_constraint(:author_id)
    |> unique_constraint(:id)
    |> unique_constraint(:alias, name: :projects_one_alias_per_author)
  end
end
