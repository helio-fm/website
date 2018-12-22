defmodule Jobs.Supervisor do
  @moduledoc false

  use Supervisor
  require Logger

  alias Jobs.Etl.Translations
  alias Jobs.Util.CollectBuilds

  def start_link(opts \\ []) do
    Logger.info IO.ANSI.magenta <> "Starting jobs supervisor" <> IO.ANSI.reset
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {Translations, []},
      {CollectBuilds, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
