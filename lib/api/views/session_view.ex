defmodule Api.SessionView do
  use Api, :view
  @moduledoc false

  def render("refresh.token.v1.json", %{jwt: jwt}) do
    %{token: jwt}
  end

  def render("session.info.v1.json", %{session: session}) do
    %{platform_id: session.platform_id,
      device_id: session.device_id,
      created_at: session.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: session.updated_at |> DateTime.to_unix(:millisecond)}
  end

  def render("session.status.v1.json", _params) do
    %{}
  end
end
