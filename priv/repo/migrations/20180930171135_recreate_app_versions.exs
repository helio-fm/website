defmodule Db.Repo.Migrations.RecreateAppVersions do
  use Ecto.Migration

  def change do
    drop table(:apps)
    create table(:app_versions) do
      add :app_name, :string, size: 16, null: false
      add :platform_type, :string, size: 16, null: false
      add :build_type, :string, size: 16, null: false
      add :architecture, :string, size: 8, null: true
      add :branch, :string, size: 8, null: false
      add :version, :string, size: 8, null: true
      add :link, :string, null: false

      timestamps()
    end

    create index(:app_versions, [:app_name]) 
    create unique_index(:app_versions, [:app_name, :platform_type, :build_type, :branch, :architecture], name: :apps_versions_constraint)
  end
end
