use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :musehackers, MusehackersWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :musehackers, Musehackers.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "123",
  database: "musehackers_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Reduce the number of rounds so it does not slow down tests
config :pbkdf2_elixir, :rounds, 1

config :musehackers, Musehackers.Auth.Token,
  secret_key: "TEST_SECRET_KEY_GUARDIAN"

config :musehackers, MusehackersWeb.Endpoint,
  secret_key_base: "TEST_SECRET_KEY_BASE"
