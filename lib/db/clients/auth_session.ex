defmodule Db.Clients.AuthSession do
  use Ecto.Schema
  import Ecto.Changeset
  alias Db.Clients.AuthSession
  @moduledoc false

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "auth_sessions" do
    field :provider, :string
    field :app_name, :string
    field :app_platform, :string
    field :app_version, :string
    field :device_id, :string
    field :secret_key, :string
    field :token, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(%AuthSession{} = auth_session, attrs) do
    auth_session
    |> cast(attrs, [:provider, :app_name, :app_version, :app_platform, :device_id])
    |> validate_required([:provider, :app_name, :app_version, :app_platform, :device_id])
    |> unique_constraint(:device_id, name: :auth_one_session_per_device)
    |> generate_secret
    |> empty_token
  end

  @doc false
  def is_stale(%AuthSession{} = auth_session) do
    DateTime.diff(auth_session.updated_at, DateTime.utc_now) > 86_400
  end

  @doc false
  def is_unfinished(%AuthSession{} = auth_session) do
    auth_session.token == nil || auth_session.token == ""
  end

  defp empty_token(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(changeset, :token, "")
      _ ->
        changeset
    end
  end

  defp generate_secret(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(changeset, :secret_key, random_string(64))
      _ ->
        changeset
    end
  end

  defp random_string(length) do
    length
      |> :crypto.strong_rand_bytes()
      |> Base.url_encode64
      |> binary_part(0, length)
  end
end
