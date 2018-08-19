use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :db, Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "musehackers_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
