defmodule Musehackers.Jobs.Supervisor do
  use Supervisor
  require Logger
  alias Musehackers.Jobs.Etl.Translations
  @moduledoc false

  def start_link(opts \\ []) do
    Logger.info IO.ANSI.magenta <> "Starting Jobs Supervisor" <> IO.ANSI.reset
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {Translations, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
