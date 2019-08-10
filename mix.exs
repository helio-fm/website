defmodule Musehackers.Mixfile do
  use Mix.Project

  def project do
    [
      app: :musehackers,
      version: "0.0.6",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Musehackers.Application, []},
      extra_applications: [:logger,
                           :runtime_tools,
                           :ueberauth,
                           :ueberauth_github,
                           :edeliver]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/api", "test/db", "test/jobs", "test/web"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.14"},
      {:phoenix_html, "~> 2.12"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 2.4"},
      {:plug_cowboy, "~> 2.0"},
      {:slugify, "~> 1.1"},

      # For auth
      {:ueberauth, "~> 0.5"},
      {:ueberauth_github, "~> 0.7"},
      {:guardian, "~> 2.0"},

      # For jobs
      {:tesla, "~> 1.1"},
      {:nimble_csv, "~> 0.4"},

      # Faster json encoding
      {:jason, "~> 1.1"},

      # For deployment
      {:edeliver, "~> 1.0"},
      {:distillery, "~> 2.0", runtime: false},

      # For tests
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.9", only: :test, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "deploy.prod": ["edeliver update production --start-deploy", "edeliver migrate production"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
