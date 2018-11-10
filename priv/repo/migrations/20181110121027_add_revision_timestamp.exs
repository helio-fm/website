defmodule Db.Repo.Migrations.AddRevisionTimestamp do
  use Ecto.Migration

  def change do

    alter table(:revisions) do
      remove :hash
      add :timestamp, :string, size: 32, null: false
    end

  end
end
