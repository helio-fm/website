defmodule Musehackers.Auth.Token do
  use Guardian, otp_app: :musehackers,
    permissions: %{
      default: [:read, :write],
      admin: [:read, :write]
    }

  use Guardian.Permissions.Bitwise
  @moduledoc false

  alias Musehackers.Repo
  alias Musehackers.Accounts.User

  def get_permissions_for(user = %User{}) do
    # TODO permissions logic
    {:ok, %{admin: [:read, :write]}}
  end

  def subject_for_token(user = %User{}, _claims) do
    {:ok, to_string(user.id)}
  end

  def subject_for_token(_, _) do
    {:error, "Unknown resource type"}
  end

  def resource_from_claims(claims) do
    {:ok, Repo.get(User, claims["sub"])}
  end

  # def resource_from_claims(_) do
  #   {:error, "Unknown resource type"}
  # end

  def build_claims(claims, _resource, opts) do
    claims =
      claims
      |> encode_permissions_into_claims!(Keyword.get(opts, :permissions))
    {:ok, claims}
  end
end
