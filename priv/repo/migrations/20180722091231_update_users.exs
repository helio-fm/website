defmodule Db.Repo.Migrations.UpdateUsersGithubInfo do
  use Ecto.Migration

  def change do

    alter table(:users) do
      add :avatar, :string, null: true
      add :location, :string, null: true
      add :github_uid, :string, size: 32, null: true
    end

    create index(:users, [:github_uid]) 

  end
end
