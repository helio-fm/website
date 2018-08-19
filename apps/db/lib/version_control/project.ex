defmodule Db.VersionControl.Project do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Db.VersionControl.Project

  @primary_key {:id, :string, autogenerate: false}

  schema "projects" do
    field :title, :string
    field :alias, :string

    field :head, :string
    field :author_id, :binary_id

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
    |> foreign_key_constraint(:head)
    |> foreign_key_constraint(:author_id)
    |> unique_constraint(:id)
    |> unique_constraint(:alias, name: :projects_one_alias_per_author)
  end

  defp generate_alias_if_needed(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{title: title, alias: nil}} ->
        generate_alias(changeset, title)
      %Ecto.Changeset{valid?: true, changes: %{title: _, alias: _}} ->
        changeset
      %Ecto.Changeset{valid?: true, changes: %{title: title}} ->
        generate_alias(changeset, title)
      _ ->
        changeset
    end
  end

  defp generate_alias(changeset, title) do
    put_change(changeset, :alias, Slug.slugify(title, separator: "-", lowercase: true))
  end
end
