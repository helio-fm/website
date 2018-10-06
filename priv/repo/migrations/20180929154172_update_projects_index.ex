defmodule Db.Repo.Migrations.UpdateProjectsIndex do
  use Ecto.Migration

  def change do
    drop index(:projects, [:alias])
    create index(:projects, [:id, :author_id])
  end
end
