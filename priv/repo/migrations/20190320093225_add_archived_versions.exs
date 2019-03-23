defmodule Db.Repo.Migrations.AddArchivedVersions do
  use Ecto.Migration

  def change do

    # have to re-create a table since ecto has a fucked up
    # constraint name mangling so we cannot delete a unique index once created
    drop table(:app_versions)
    create table(:app_versions) do
      add :app_name, :string, size: 16, null: false
      add :platform_type, :string, size: 16, null: false
      add :build_type, :string, size: 16, null: false
      add :architecture, :string, size: 8, null: true
      add :branch, :string, size: 8, null: false
      add :version, :string, size: 8, null: false
      add :link, :string, null: false
      add :is_archived, :boolean, default: false, null: false

      timestamps()
    end

    # all fields except link and is_archived are meant to be unique
    # there cannot be neither two versions with different links
    # nor two different versions with different archived state
    create unique_index(:app_versions,
      [:app_name, :platform_type, :build_type, :branch, :architecture, :version],
      name: :app_versions_constraint)

    # for faster fetching latest versions:
    create index(:app_versions, [:app_name])
    create index(:app_versions, [:app_name, :platform_type, :is_archived])

  end
end
