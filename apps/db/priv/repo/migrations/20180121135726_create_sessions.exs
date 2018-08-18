defmodule Db.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :token, :text, null: false # may be longer than 255 chars
      add :device_id, :string, null: false
      add :platform_id, :string, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:sessions, [:user_id])

    # There can be only one session per device for a user:
    create unique_index(:sessions, [:user_id, :device_id], name: :sessions_one_session_per_device)
    # create constraint(:sessions, :sessions_one_session_per_device, check: "UNIQUE(user_id, device_id)")
  end
end
