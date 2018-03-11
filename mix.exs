defmodule Musehackers.Mixfile do
  use Mix.Project

  def project do
    [
      app: :musehackers,
      version: "0.0.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls": :test,
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
                           :edeliver,
                           :comeonin,
                           :proper_case]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.3.0"},
      {:postgrex, ">= 0.13.3"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      # For auth
      {:guardian, "~> 1.0.0"},
      {:comeonin, "~> 4.0.3"},
      {:pbkdf2_elixir, "~> 0.12.3"},

      # For jobs
      {:tesla, "~> 0.10.0"},
      {:nimble_csv, "~> 0.4"},

      # Faster json encoding and case transform
      {:jason, "~> 1.0"},
      {:proper_case, "~> 1.1"},

      # For deployment
      {:distillery, "~> 1.0"},
      {:edeliver, "~> 1.4.4"},

      # For tests
      {:credo, "~> 0.9.0-rc3", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.8", only: :test}
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
      "deploy.prod": ["edeliver update production --start-deploy --run-migrations"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
