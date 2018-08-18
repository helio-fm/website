defmodule Db.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :login, :string, size: 32, null: true
      add :email, :string, null: false
      add :name, :string, null: true
      add :password_hash, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:login])
  end
end
