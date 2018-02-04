defmodule Musehackers.Accounts.Session do
  use Ecto.Schema
  import Ecto.Changeset
  alias Musehackers.Accounts
  alias Musehackers.Accounts.Session
  @moduledoc """
  The Session model.
  A user can only have one active session per device.
  """

  schema "sessions" do
    field :token, :string
    field :device_id, :string
    field :platform_id, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(%Session{} = session, attrs) do
    session
    |> cast(attrs, [:user_id, :token, :device_id, :platform_id])
    |> validate_required([:token, :device_id, :platform_id])
    |> unique_constraint(:device_id, name: :sessions_one_session_per_device)
  end

  def update_token_for_device(user_id, device_id, platform_id, token) do
    payload = %{user_id: user_id, device_id: device_id, platform_id: platform_id, token: token}
    case Accounts.create_or_update_session(payload) do
      {:error, _} -> {:error, :session_update_failed}
      {:ok, _inserted} -> {:ok, token}
    end
  end
end
