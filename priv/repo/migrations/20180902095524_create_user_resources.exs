defmodule Db.Repo.Migrations.CreateUserResources do
  use Ecto.Migration

  def change do
    drop table(:resources)
    create table(:app_resources) do
      add :resource_name, :string, size: 32, null: false
      add :app_name, :string, size: 32, null: false
      add :hash, :string, null: false
      add :data, :map, null: false

      timestamps()
    end

    create index(:app_resources, [:resource_name])
    create unique_index(:app_resources, [:app_name, :resource_name], name: :resources_one_resource_per_app)

    create table(:user_resources) do
      add :resource_name, :string, size: 32, null: false
      add :hash, :string, null: false
      add :data, :map, null: false
      add :owner_id, references(:users, on_delete: :nothing, column: :id, type: :binary_id), null: false

      timestamps()
    end

    create index(:user_resources, [:owner_id])
    create unique_index(:user_resources, [:owner_id, :resource_name], name: :resources_one_resource_per_user)
  end
end
