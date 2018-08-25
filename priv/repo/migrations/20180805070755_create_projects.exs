defmodule Db.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :string, primmary_key: true, null: false
      add :title, :string, null: false
      add :alias, :string, null: false
      add :author_id, references(:users, on_delete: :nothing, column: :id, type: :binary_id), null: false

      timestamps()
    end

    create index(:projects, [:alias])
    create index(:projects, [:author_id])
    create unique_index(:projects, [:id])
    create unique_index(:projects, [:author_id, :alias], name: :projects_one_alias_per_author)
  end
end
