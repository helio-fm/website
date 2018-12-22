defmodule Db.Repo.Migrations.UpdateAppsIndex do
  use Ecto.Migration

  def change do

    # replace unique index with usual one
    drop index(:apps, [:app_name]) 
    create index(:apps, [:app_name]) 
    create unique_index(:apps, [:app_name, :platform_id], name: :apps_one_version_per_platform)

  end
end

