defmodule Db.Repo.Migrations.CreateRevisions do
  use Ecto.Migration

  def change do
    create table(:revisions, primary_key: false) do
      add :id, :string, primary_key: true, null: false
      add :message, :string, null: false
      add :hash, :string, null: false
      add :data, :map, null: false
      add :project_id, references(:projects, on_delete: :nothing, column: :id, type: :string), null: false
      add :parent_id, references(:revisions, on_delete: :nothing, column: :id, type: :string), null: true

      timestamps()
    end

    create index(:revisions, [:project_id])
    create index(:revisions, [:parent_id])
    create unique_index(:revisions, [:id, :project_id], name: :revisions_unique_id_per_project)

    alter table(:projects) do
      add :head, references(:revisions, on_delete: :nothing, column: :id, type: :string), null: true
    end
  end
end
