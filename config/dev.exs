use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :musehackers, Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  secret_key_base: "DEV_SECRET_KEY_BASE_DEV_SECRET_KEY_BASE_DEV_SECRET_KEY_BASE_DEV_SECRET",
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []


config :musehackers, Api.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4001],
  secret_key_base: "DEV_SECRET_KEY_BASE_DEV_SECRET_KEY_BASE_DEV_SECRET_KEY_BASE_DEV_SECRET",
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# Watch static and templates for browser reloading.
config :musehackers, Web.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/web/views/.*(ex)$},
      ~r{lib/web/templates/.*(eex)$}
    ]
  ]

config :musehackers, Api.Endpoint,
  live_reload: [
    patterns: [
      ~r{lib/api/views/.*(ex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :musehackers, Api.Auth.Token,
  secret_key: "DEV_SECRET_KEY_GUARDIAN"

# Configure your database
config :musehackers, Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "musehackers",
  hostname: "localhost",
  pool_size: 10
