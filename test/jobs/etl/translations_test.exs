defmodule Jobs.Etl.TranslationsTest do
  use Jobs.DataCase

  alias Jobs.Etl.Translations
  alias Db.Clients.Resource

  setup do
    Tesla.Mock.mock fn
      _env -> %Tesla.Env{status: 200, headers: [{"content-type", "text/csv"}],
        body: ",,\"test\",,,\nID,,en\n::locale,,English\n::plural,,({x}==1 ? 1 : 2)\na::b::c,test,abc\nPlural:,,,,,\n{x} a,,\"{x} a\n{x} a\""}
    end
    :ok
  end

  describe "translations" do

    @valid_translations_map %{
      translations: %{
        locale: [
          %{
            id: "en",
            name: "English",
            pluralEquation: "({x}==1 ? 1 : 2)",
            literal: [
              %{name: "defaults::newproject::firstcommit", translation: "Project started"},
              %{name: "defaults::newproject::name", translation: "New project"}],
            pluralLiteral: [
              %{name: "{x} input channels", translation: [
                  %{name: "{x} input channel", pluralForm: "1"},
                  %{name: "{x} input channels", pluralForm: "2"}]},
              %{name: "{x} output channels", translation: [
                  %{name: "{x} output channel", pluralForm: "1"},
                  %{name: "{x} output channels", pluralForm: "2"}]}]
          },
          %{
            id: "ru",
            name: "Русский",
            pluralEquation: "({x}%10==1 && {x}%100!=11 ? 1 : {x}%10>=2 && {x}%10<=4 && ({x}%100<10 || {x}%100>=20) ? 2 : 3)",
            literal: [
              %{name: "defaults::newproject::firstcommit", translation: "Проект создан"},
              %{name: "defaults::newproject::name", translation: "Новый проект"}],
            pluralLiteral: [
              %{name: "{x} input channels", translation: [
                  %{name: "{x} входной канал", pluralForm: "1"},
                  %{name: "{x} входных канала", pluralForm: "2"},
                  %{name: "{x} входных каналов", pluralForm: "3"}]},
              %{name: "{x} output channels", translation: [
                  %{name: "{x} выходной канал", pluralForm: "1"},
                  %{name: "{x} выходных канала", pluralForm: "2"},
                  %{name: "{x} выходных каналов", pluralForm: "3"}]}]
          },
          %{
            id: "ja",
            name: "日本語",
            pluralEquation: "1",
            literal: [
              %{name: "defaults::newproject::firstcommit", translation: "プロジェクト開始"},
              %{name: "defaults::newproject::name", translation: "新規プロジェクト"}],
            pluralLiteral: [
              %{name: "{x} input channels", translation: [%{name: "{x} 入力チャンネル", pluralForm: "1"}]},
              %{name: "{x} output channels", translation: [%{name: "{x} 出力チャンネル", pluralForm: "1"}]}]
          }          
        ]
      }
    }

    @valid_imported_csv ",,\"This document is distributed under the terms of CC-BY (https://creativecommons.org/licenses/by/3.0)
By editing or commenting this document you agree to distribute all your changes and suggestions under the same terms and conditions.\",,// need to fix fonts in the app,// TODO
ID,,en,ru,ja,nl
::locale,,English,Русский,日本語,Nederlands
::plural,,({x}==1 ? 1 : 2),({x}%10==1 && {x}%100!=11 ? 1 : {x}%10>=2 && {x}%10<=4 && ({x}%100<10 || {x}%100>=20) ? 2 : 3),1,({x}==1 ? 1 : 2)
defaults::newproject::firstcommit,The name of the very first changeset,Project started,Проект создан,プロジェクト開始,Project gestart
defaults::newproject::name,Default names or the new items created by user,New project,Новый проект,新規プロジェクト,Nieuw project
Plural forms:,,,,,
{x} input channels,,\"{x} input channel
{x} input channels\",\"{x} входной канал
{x} входных канала
{x} входных каналов\",{x} 入力チャンネル,\"{X} ingangskanaal
{X} ingangskanalen\"
{x} output channels,,\"{x} output channel
{x} output channels\",\"{x} выходной канал
{x} выходных канала
{x} выходных каналов\",{x} 出力チャンネル,\"{X} uitgangskanaal
{X} uitgangskanalen\""

    test "transform/1 returns properly transformed translations map" do
      {:ok, resource_map} = Translations.transform(@valid_imported_csv)
      assert resource_map.data == @valid_translations_map
      assert resource_map.app_name == "helio"
      assert resource_map.type == "translations"
      assert resource_map.hash != ""
    end

    test "the resource is created after GenServer.call" do
      {:reply, _resource, _state} = Translations.handle_call(:process, :from, :state)
      users = Resource |> Repo.all
      assert Enum.count(users) == 1
    end
  end
end
