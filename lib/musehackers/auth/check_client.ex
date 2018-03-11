defmodule Musehackers.Auth.CheckClient do
  @moduledoc false

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    headers = get_req_header(conn, "client")
    case headers do
      [] -> conn |> put_status(:unauthorized) |> send_resp(:unauthorized, "") |> halt
      _ -> conn #%{conn | client_id: headers |> List.first}
    end
  end
end
