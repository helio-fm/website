defmodule Musehackers.Jobs.Etl.Translations do
  @moduledoc """
  Simple ETL tool to fetch latest Helio translations and store them in a resource table
  """

  use GenServer
  require Logger
  import Musehackers.Jobs.Etl.Helpers
  alias Musehackers.Clients
  alias Musehackers.Clients.Resource
  alias NimbleCSV.RFC4180, as: CSV
  alias NimbleCSV.ParseError

  def source_url do
    doc_key = System.get_env("ETL_DOC_TRANSLATIONS")
    "https://docs.google.com/feeds/download/spreadsheets/Export?key=#{doc_key}&exportFormat=csv&gid=0"
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    try do
      Logger.info IO.ANSI.magenta <> "Starting Helio translations update job as " <> to_string(__MODULE__) <> IO.ANSI.reset
      schedule_work()
      {:ok, nil}
    rescue
      exception ->
         Logger.error inspect exception
         :ignore
    end
  end

  # Async call used by schedule_work() with Process.send_after
  def handle_info(:process, state) do
    extract_transform_load(source_url())
    schedule_work()
    {:noreply, state}
  end

  # Sync call used by web controller to fetch translations immediately:
  # GenServer.call(Musehackers.Jobs.Etl.Translations, :process)
  def handle_call(:process, _from, state) do
    resource = extract_transform_load(source_url())
    {:reply, resource, state}
  end

  defp extract_transform_load(source_url) do
    with {:ok, body} <- download(source_url),
         {:ok, resource_attrs} = transform(body),
    do: Clients.create_or_update_resource(resource_attrs)
  end

  def transform(body) do
    with {:ok, parsed_csv} <- parse_csv(body),
         {:ok, cleaned_up_csv} <- remove_draft_translations(parsed_csv),
         {:ok, locales_list} <- transform_translations_map(cleaned_up_csv),
    do: {:ok, to_resource(%{"translations": %{"locale": locales_list}})}
  end

  defp to_resource(translations) do
    %{"app_name": "helio",
    "data": translations,
    "hash": Resource.hash(translations),
    "resource_name": "translations"}
  end

  defp schedule_work do
    wait = 1000 * 60 * 60 * 12 # 12 hours
    Process.send_after(self(), :process, wait)
  end

  defp parse_csv(body) do
    try do
      parsed_list = CSV.parse_string(body, headers: false)
      {:ok, parsed_list}
    rescue
      ParseError -> {:error, "Failed to parse CSV"}
    end
  end

  defp remove_draft_translations(translations) do
    headers = Enum.at(translations, 0)
    result = translations
      |> Enum.map(fn(x) ->
        # Iterate sublists to remove columns marked as incomplete
        Enum.filter(x, fn(y) -> columt_belongs_to_draft(headers, x, y) end)
      end)
    {:ok, result}
  end

  defp columt_belongs_to_draft(headers, column, token) do
    index = column |> Enum.find_index(fn(x) -> x == token end)
    is_draft = String.downcase(Enum.at(headers, index)) =~ "todo"
    !is_draft
  end

  defp transform_translations_map(translations) do
    ids = translations |> Enum.at(1) |> Enum.with_index(0)
    names = translations |> Enum.at(2)
    formulas = translations |> Enum.at(3)

    # At this point raw data is like:
    # [
    #  ["defaults::newproject::firstcommit", "The name of the very first changeset", "Project started", "Проект создан", "プロジェクト開始"],
    #  ["defaults::newproject::name", "Default names or the new items created by user", "New project", "Новый проект", "新規プロジェクト"],
    #  ["Plural forms:", "", "", "", "", ""],
    #  ["{x} input channels", "", "{x} input channel\n{x} input channels", "{x} входной канал\n{x} входных канала\n{x} входных каналов", "{x} 入力チャンネル"],
    #  ["{x} output channels", "", "{x} output channel\n{x} output channels", "{x} выходной канал\n{x} выходных канала\n{x} выходных каналов", "{x} 出力チャンネル"]
    # ]
    data = remove_headers(translations)

    # Convert sub-lists values into tuples with indexes for simplier pasring:
    indexed_data = data |> Enum.map(fn(x) -> Enum.with_index(x, 0) end)

    result = ids
      |> Enum.flat_map(fn{x, i} ->
        case x != "ID"  && x != "" do
          true -> [%{
              "id": x,
              "name": Enum.at(names, i),
              "pluralEquation": Enum.at(formulas, i),
              "literal": extract_singulars(indexed_data, i),
              "pluralLiteral": extract_plurals(indexed_data, i)
            }]
          false -> []
        end
      end)
    {:ok, result}
  end

  defp extract_singulars(translations, locale_index) do
    translations
      |> Enum.flat_map(fn(x) ->
        name = x |> Enum.at(0) |> elem(0)
        translation = x |> Enum.at(locale_index) |> elem(0)
        case translation == "" || name =~ "{x}" do
          false -> [%{
            "name": name,
            "translation": translation
          }]
          true -> []
        end
      end)
  end

  defp extract_plurals(translations, locale_index) do
    translations
      |> Enum.flat_map(fn(x) ->
        name = x |> Enum.at(0) |> elem(0)
        translations = x |> Enum.at(locale_index) |> elem(0)
        case translations != "" && name =~ "{x}" do
          true -> [%{
            "name": name,
            "translation": split_plural_forms(translations)
          }]
          false -> []
        end
      end)
  end

  defp split_plural_forms(string) do
    string
      |> String.split(["\n", "\r"])
      |> Enum.with_index(1)
      |> Enum.map(fn{x, i} -> 
        %{
          "name": x,
          "pluralForm": Integer.to_string(i)
        }
      end)
  end

  defp remove_headers(translations) do
    translations
      |> Enum.with_index(0)
      |> Enum.filter(fn{_, i} -> i > 3 end)
      |> Enum.map(fn{x, _} -> x end)
  end
end
