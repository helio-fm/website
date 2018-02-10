defmodule Musehackers.Jobs.Etl.Translations do
  @moduledoc """
  Simple ETL tool to fetch latest Helio translations and store them in a resource table
  """

  use GenServer
  require Logger
  import Musehackers.Jobs.Etl.Helpers
  alias Musehackers.Clients.Resource
  alias NimbleCSV.RFC4180, as: CSV

  def googledoc_export_link do
    "http://docs.google.com/feeds/download/spreadsheets/Export?key=todo&exportFormat=csv&gid=0"
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    Logger.info IO.ANSI.magenta <> "Starting Helio translations update job" <> IO.ANSI.reset
    try do
      source_url = googledoc_export_link()
      schedule_work()
      {:ok, source_url}
    rescue
      exception ->
         Logger.error inspect exception
         :ignore
    end
  end

  defp schedule_work do
    wait = 1000 * 60 * 60 * 12 # 12 hours
    Process.send_after(self(), :work, wait)
  end

  def handle_info(:work, source_url) do
    # with {:ok, body} <- download(source_url),
    #      {:ok, parsed_csv} <- parse_csv(body),
    #      {:ok, cleaned_up_csv} <- remove_invalid_translations(parsed_csv),
    #      {:ok, final_translations_map} = todo_todo(cleaned_up_csv)
    # do: Clients.update_resource(:helio, :translations, final_translations_map)
    schedule_work()
    {:noreply, source_url}
  end

  def parse_csv(body) do
    Logger.info "Parsing csv: #{body}"
    parsed_list = CSV.parse_string body
    # TODO
  end

  def remove_invalid_translations(csv) do
    Logger.info "Removing invalid translaitions"
    # TODO
  end
end
