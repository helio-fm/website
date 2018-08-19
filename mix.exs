defmodule Musehackers.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      # For deployment
      {:edeliver, ">= 1.6.0"},
      {:distillery, "~> 2.0", warn_missing: false},

      # For tests
      {:credo, "~> 0.9.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.9", only: :test}
    ]
  end
end
