defmodule Web.Mixfile do
  use Mix.Project

  def project do
    [
      app: :web,
      version: "0.0.6",
      elixir: "~> 1.6",
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
      mod: {Web.Application, []},
      extra_applications: [:logger,
                           :runtime_tools,
                           :ueberauth,
                           :ueberauth_github,
                           :edeliver]
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
      # Internal
      {:db, in_umbrella: true},
      {:api, in_umbrella: true},
      {:jobs, in_umbrella: true},

      # Phoenix
      {:phoenix, "~> 1.3.4"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      # For auth
      {:ueberauth, "~> 0.5"},
      {:ueberauth_github, "~> 0.7.0"},

      # For deployment
      {:distillery, "~> 1.5"},
      {:edeliver, "~> 1.5.3"},

      # For tests
      {:credo, "~> 0.9.0", only: [:dev, :test], runtime: false},
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
      "deploy.prod": ["edeliver update production --start-deploy", "edeliver migrate production"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
