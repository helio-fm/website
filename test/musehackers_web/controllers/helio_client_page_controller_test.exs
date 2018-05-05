defmodule MusehackersWeb.HelioClientPageControllerTest do
  use MusehackersWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Built with ❤ in a garage in Izhevsk, Russia"
  end
end
