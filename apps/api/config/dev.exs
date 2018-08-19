use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :api, Api.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4001],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# Watch static and templates for browser reloading.
config :api, Api.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/views/.*(ex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :api, Api.Auth.Token,
  secret_key: "DEV_SECRET_KEY_GUARDIAN"

config :api, Api.Endpoint,
  secret_key_base: "DEV_SECRET_KEY_BASE_DEV_SECRET_KEY_BASE_DEV_SECRET_KEY_BASE_DEV_SECRET"
