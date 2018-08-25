defmodule Api.Auth.Token do
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

  alias Db.Repo
  alias Db.Accounts.User

  def get_permissions_for(%User{} = user) do
    # Just a temporary hack :)
    if user.email == "peter.rudenko@gmail.com" do
      {:ok, %{admin: [:read, :write]}}
    else
      {:ok, %{default: [:read]}}
    end
  end

  def subject_for_token(%User{} = user, _claims) do
    {:ok, to_string(user.id)}
  end

  def subject_for_token(_, _) do
    {:error, "Unknown resource type"}
  end

  def resource_from_claims(claims) do
    case Repo.get(User, claims["sub"]) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def build_claims(claims, _resource, opts) do
    claims =
      claims
      |> encode_permissions_into_claims!(Keyword.get(opts, :permissions))
    {:ok, claims}
  end
end
