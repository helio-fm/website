use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :musehackers, Web.Endpoint,
  http: [port: 4100],
  secret_key_base: "TEST_SECRET_KEY_BASE_TEST_SECRET_KEY_BASE_TEST_SECRET_KEY_BASE_TEST",
  server: false

config :musehackers, Api.Endpoint,
  http: [port: 4101],
  secret_key_base: "TEST_SECRET_KEY_BASE_TEST_SECRET_KEY_BASE_TEST_SECRET_KEY_BASE_TEST",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :musehackers, Db.Repo,
  username: "postgres",
  password: "",
  database: "musehackers_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Reduce the number of rounds so it does not slow down tests
config :pbkdf2_elixir, :rounds, 1

config :musehackers, Api.Auth.Token,
  secret_key: "TEST_SECRET_KEY_GUARDIAN",
  token_verify_module: Guardian.Token.Jwt.Verify,
  allowed_algos: ["HS512"],
  allowed_drift: 0

# Use mock adapter for all clients
config :tesla, adapter: Tesla.Mock

# Locations
config :musehackers, images_path: "./test"
config :musehackers, builds_path: "./test"
