defmodule Db.Repo.Migrations.CreateApps do
  use Ecto.Migration

  def change do
    create table(:apps) do
      add :app_name, :string
      add :platform_id, :string
      add :version, :string
      add :link, :string

      timestamps()
    end

    create unique_index(:apps, [:app_name])

  end
end
