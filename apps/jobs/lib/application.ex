defmodule Jobs.Application do
  use Application
  @moduledoc """
  See https://hexdocs.pm/elixir/Application.html
  for more information on OTP Applications
  """

  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the supervisor for scheduled ETL jobs
      supervisor(Jobs.Supervisor, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Etl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
