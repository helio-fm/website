defmodule Musehackers.Auth.Token do
  @moduledoc """
  Guardian encodes permissions into bitstrings.
  Because of this, permissions should keep their positions when refactoring.
  Permissions should not be re-ordered (renamings are fine though),
  and removals need to keep their place in the list.
  """

  use Guardian, otp_app: :musehackers,
    permissions: %{
      default: [:read],
      admin: [:read, :write]
    }

  use Guardian.Permissions.Bitwise

  alias Musehackers.Repo
  alias Musehackers.Accounts.User

  def get_permissions_for(user = %User{}) do
    cond do
      user.is_admin ->
        {:ok, %{admin: [:read, :write]}}
      true ->
        {:ok, %{default: [:read]}}
    end
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
