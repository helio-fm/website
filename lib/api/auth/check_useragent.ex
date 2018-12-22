defmodule Api.Auth.CheckUserAgent do
  @moduledoc false

  def check_against_app_name(conn, app_name) do
    with [agent] <- Plug.Conn.get_req_header(conn, "user-agent"),
         true <- String.contains?(String.downcase(agent), app_name) do
      {:ok, agent}
    else
      _ -> {:error, :user_agent_mismatch}
    end
  end
end
