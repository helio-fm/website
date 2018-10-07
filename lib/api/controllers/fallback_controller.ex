defmodule Api.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use Api, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Api.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(Api.ErrorView, :"404")
  end

  def call(conn, {:error, :login_failed}), do: unauthorized(conn, "authentication failed")
  def call(conn, {:error, :login_not_found}), do: unauthorized(conn, "authentication failed, login not found")
  def call(conn, {:error, :session_update_failed}), do: unauthorized(conn, "failed to re-issue a token")
  def call(conn, {:error, :invalid_session}), do: unauthorized(conn, "failed to re-issue a token, no valid session")
  def call(conn, {:error, :session_not_found}), do: not_found(conn, "session not found")
  def call(conn, {:error, :client_not_found}), do: not_found(conn, "client not found")
  def call(conn, {:error, :resource_not_found}), do: not_found(conn, "resource not found")
  def call(conn, {:error, :project_not_found}), do: not_found(conn, "project not found")
  def call(conn, {:error, :revision_not_found}), do: not_found(conn, "revision not found")
  def call(conn, {:error, :user_agent_mismatch}), do: unauthorized(conn, "user agent mismatch")

  defp unauthorized(conn, message) do
    conn
    |> put_status(:unauthorized)
    |> render(Api.ErrorView, "error.json", status: :unauthorized, message: message)
  end

  defp not_found(conn, message) do
    conn
    |> put_status(:not_found)
    |> render(Api.ErrorView, "error.json", status: :not_found, message: message)
  end
end
