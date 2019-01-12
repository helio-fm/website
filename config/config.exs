# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :musehackers, ecto_repos: [Db.Repo]

# Configures the endpoints
config :musehackers, Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: Web.ErrorView, accepts: ~w(html json)]

config :musehackers, Api.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: Api.ErrorView, accepts: ~w(html json)]

# Configure Guardian for JWT authentication
config :musehackers, Api.Auth.Token,
  issuer: "hfm",
  secret_key: System.get_env("SECRET_KEY_GUARDIAN"),
  token_verify_module: Guardian.Token.Jwt.Verify,
  allowed_algos: ["HS512"],
  ttl: {8, :days},
  allowed_drift: 2000,
  verify_issuer: true

# Configure OAuth authentication providers
config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github,
      [default_scope: "read:user,user:email", send_redirect_uri: false]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure encoders
config :phoenix, :format_encoders,
  json: Api.Plugs.CamelCaseEncoder

config :phoenix, :json_library, Jason

# Mime types for versioning
config :mime, :types, %{
  "application/helio.fm.v1+json" => [:v1]
}

# Locations
config :musehackers, users_base_url: "https://helio.fm/"
config :musehackers, builds_base_url: "https://ci.helio.fm/"
config :musehackers, images_base_url: "https://img.helio.fm/"
config :musehackers, images_path: "/opt/musehackers/files/img/"
config :musehackers, builds_path: "/opt/musehackers/files/ci/"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
