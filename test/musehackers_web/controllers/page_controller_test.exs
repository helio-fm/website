defmodule MusehackersWeb.PageControllerTest do
  use MusehackersWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Muse Hackers"
    assert html_response(conn, 200) =~ "Sign in with Facebook"
  end
end
