defmodule Musehackers.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create table(:resources) do
      add :resource_name, :string, size: 32, null: false
      add :app_name, :string, size: 32, null: false
      add :hash, :string, null: false
      add :data, :map, null: false

      timestamps()
    end

    create index(:resources, [:resource_name])
    create unique_index(:resources, [:app_name, :resource_name], name: :resources_one_resource_per_app)

  end
end
