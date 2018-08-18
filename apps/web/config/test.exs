use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :web, Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :web, Web.Endpoint,
  secret_key_base: "TEST_SECRET_KEY_BASE_TEST_SECRET_KEY_BASE_TEST_SECRET_KEY_BASE__"

# Use mock adapter for all clients
config :tesla, adapter: Tesla.Mock
