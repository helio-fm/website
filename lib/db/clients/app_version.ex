defmodule Db.Clients.AppVersion do
  use Ecto.Schema
  import Ecto.Changeset
  alias Db.Clients.AppVersion
  @moduledoc false

  schema "app_versions" do
    field :app_name, :string
    field :platform_type, :string
    field :build_type, :string
    field :architecture, :string
    field :branch, :string
    field :version, :string
    field :link, :string
    field :is_archived, :boolean

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%AppVersion{} = app, attrs) do
    app
    |> cast(attrs, [:app_name, :platform_type, :build_type, :architecture, :branch, :version, :link, :is_archived])
    |> validate_required([:app_name, :platform_type, :build_type, :architecture, :branch, :link])
    |> unique_constraint(:app_name, name: :app_versions_constraint)
  end

  def detect_platform(user_agent) do
    cond do
      String.match?(user_agent, ~r/Android/) ->
        {:ok, "android"}
      String.match?(user_agent, ~r/(iPad|iPhone|iPod|iOS)/) ->
        {:ok, "ios"}
      String.match?(user_agent, ~r/(Mac OS|macOS)/) ->
        {:ok, "macos"}
      String.match?(user_agent, ~r/(Linux|FreeBSD)/) ->
        {:ok, "linux"}
      String.match?(user_agent, ~r/Windows/) ->
        {:ok, "windows"}
      true ->
        {:error, :unknown_platform}
    end
  end

  def detect_architecture(user_agent) do
    if String.match?(user_agent, ~r/(WOW64|Win64|x86_64|64-bit)/) do
      "64-bit"
    else
      "32-bit"
    end
  end
end
