defmodule Musehackers.Repo.Migrations.CreateAuthSessions do
  use Ecto.Migration

  def change do
    create table(:auth_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider, :string, null: false
      add :app_name, :string, null: false
      add :app_version, :string, null: false
      add :app_platform, :string, null: false
      add :device_id, :string, null: false
      add :secret_key, :string, null: false
      add :token, :text, null: true

      timestamps()
    end

    create unique_index(:auth_sessions, [:provider, :device_id], name: :auth_one_session_per_device)
  end
end
