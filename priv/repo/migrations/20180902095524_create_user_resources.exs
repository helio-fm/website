defmodule Db.Repo.Migrations.CreateUserResources do
  use Ecto.Migration

  def change do
    drop table(:resources)
    create table(:app_resources) do
      add :app_name, :string, size: 32, null: false
      add :type, :string, size: 32, null: false
      add :hash, :string, null: false
      add :data, :map, null: false

      timestamps()
    end

    create index(:app_resources, [:type])
    create unique_index(:app_resources, [:app_name, :type], name: :app_resources_one_type_per_app)

    create table(:user_resources) do
      add :owner_id, references(:users, on_delete: :nothing, column: :id, type: :binary_id), null: false
      add :type, :string, size: 32, null: false
      add :name, :string, null: false
      add :hash, :string, null: false
      add :data, :map, null: false

      timestamps()
    end

    create index(:user_resources, [:owner_id])
    create unique_index(:user_resources, [:owner_id, :type, :name],
      name: :user_resources_one_name_per_user)
  end
end
