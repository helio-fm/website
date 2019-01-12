defmodule Jobs.Util.CleanupStaleSessions do
  @moduledoc """
  A job to remove all sliding sessions with token expired
  """

  use GenServer
  require Logger

  alias Db.Accounts
  alias Api.Auth.Token

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    try do
      Logger.info IO.ANSI.magenta <> "Starting Helio sessions cleanup job as " <> to_string(__MODULE__) <> IO.ANSI.reset
      schedule_work()
      {:ok, nil}
    rescue
      exception -> Logger.error inspect exception
      :ignore
    end
  end

  def handle_info(:process, state) do
    cleanup_sessions()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :process, 1000 * 60 * 60 * 3) # 3h
  end

  def cleanup_sessions() do
    # Get all sessions updated within the last week,
    # which should be enough, since the script works every 3 hr
    {:ok, sessions} = Accounts.get_recent_tokens(60 * 60 * 24 * 7)
    stale_sessions = sessions |> Enum.filter(fn x -> token_is_invalid(x.token) end)
    num_sessions_deleted = stale_sessions |> Enum.count
    for session <- stale_sessions do
      Accounts.delete_session(session)
    end
    num_sessions_deleted
  end

  defp token_is_invalid(token) do
    {result, _} = Token.decode_and_verify(token)
    result == :error
  end
end
