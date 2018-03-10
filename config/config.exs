# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :musehackers,
  ecto_repos: [Musehackers.Repo]

# Configures the endpoint
config :musehackers, MusehackersWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: MusehackersWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Musehackers.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configure Guardian for JWT authentication
config :musehackers, Musehackers.Auth.Token,
  issuer: "musehackers",
  secret_key: System.get_env("SECRET_KEY_GUARDIAN"),
  token_verify_module: Guardian.Token.Jwt.Verify,
  allowed_algos: ["HS512"],
  ttl: { 8, :days },
  allowed_drift: 2000,
  verify_issuer: true

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :format_encoders,
  json: ProperCase.JSONEncoder.CamelCase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
