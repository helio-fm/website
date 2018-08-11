defmodule Musehackers.VersionControl.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias Musehackers.VersionControl.Project
  alias Musehackers.VersionControl.Revision
  alias Musehackers.Accounts.User

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :binary_id

  schema "projects" do
    field :title, :string
    field :alias, :string

    has_one :head, Revision, foreign_key: :id
    belongs_to :author, User, foreign_key: :author_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Project{} = project, attrs) do
    project
    |> cast(attrs, [:id, :title, :alias, :author_id])
    |> validate_required([:id, :title])
    |> validate_length(:title, min: 2, max: 32)
    |> generate_alias_if_needed()
    |> validate_length(:alias, min: 2, max: 32)
    |> validate_format(:alias, ~r/^[a-z0-9.-]*$/, [message: "only lowercase letters and numbers and (.-) allowed"])
    |> foreign_key_constraint(:author_id)
    |> unique_constraint(:id)
    |> unique_constraint(:alias, name: :projects_one_alias_per_author)
  end

  defp generate_alias_if_needed(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{title: title, alias: nil}} ->
        put_change(changeset, :alias, Slug.slugify(title, separator: "-", lowercase: true))
      _ ->
        changeset
    end
  end
end
