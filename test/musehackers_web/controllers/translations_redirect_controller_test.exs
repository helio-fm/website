defmodule MusehackersWeb.TranslationsRedirectControllerTest do
  use MusehackersWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/translations"
    assert conn.status == 302
    assert String.contains?(conn.resp_body, "href=\"https:")
  end

end
