use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

# Use mock adapter for all clients
config :tesla, adapter: Tesla.Mock
