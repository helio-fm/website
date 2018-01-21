defmodule Musehackers.Accounts.Session do
  use Ecto.Schema
  import Ecto.Changeset
  alias Musehackers.Accounts.Session
  @moduledoc """
  The Session model.
  A user can only have one active session per device.
  """

  schema "sessions" do
    field :device_id, :string
    field :token, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(%Session{} = session, attrs) do
    session
    |> cast(attrs, [:token, :device_id])
    |> validate_required([:token, :device_id])
  end
end
