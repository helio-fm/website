defmodule Db.Repo.Migrations.AddFileSizeDate do
  use Ecto.Migration

  def change do

    alter table(:app_versions) do
      add :file_size, :integer, default: 0, null: false
      add :file_date, :utc_datetime, default: fragment("now()"), null: false
    end

  end
end
