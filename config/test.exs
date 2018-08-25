use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :musehackers, Web.Endpoint,
  http: [port: 4100],
  server: false

config :musehackers, Api.Endpoint,
  http: [port: 4101],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :musehackers, Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "musehackers_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Reduce the number of rounds so it does not slow down tests
config :pbkdf2_elixir, :rounds, 1

config :musehackers, Api.Auth.Token,
  secret_key: "TEST_SECRET_KEY_GUARDIAN"

config :musehackers, Web.Endpoint,
  secret_key_base: "TEST_SECRET_KEY_BASE_TEST_SECRET_KEY_BASE_TEST_SECRET_KEY_BASE__"

config :musehackers, Api.Endpoint,
  secret_key_base: "TEST_SECRET_KEY_BASE_TEST_SECRET_KEY_BASE_TEST_SECRET_KEY_BASE__"

# Use mock adapter for all clients
config :tesla, adapter: Tesla.Mock
