use Mix.Config

# Do not print debug messages in production
config :logger, level: :info

# Configure the database
config :db, Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_USERNAME"),
  password: System.get_env("DATABASE_PASSWORD"),
  hostname: System.get_env("DATABASE_HOSTNAME"),
  database: "musehackers",
  pool_size: 15
