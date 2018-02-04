defmodule MusehackersWeb.Api.V1.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use MusehackersWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(MusehackersWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(MusehackersWeb.ErrorView, :"404")
  end

  def call(conn, {:error, :login_failed}), do: login_failed(conn)
  def call(conn, {:error, :login_not_found}), do: login_failed(conn)
  def call(conn, {:error, :session_update_failed}), do: login_failed(conn)
  def call(conn, {:error, :session_not_found}), do: login_failed(conn)

  defp login_failed(conn) do
    conn
    |> put_status(:unauthorized)
    |> render(MusehackersWeb.ErrorView, "error.json", status: :unauthorized, message: "Authentication failed!")
  end
end
