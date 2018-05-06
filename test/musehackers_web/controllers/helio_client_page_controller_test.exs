defmodule MusehackersWeb.HelioClientPageControllerTest do
  use MusehackersWeb.ConnCase
  alias Musehackers.Clients

  describe "renders Helio page" do
    setup [:create_clients]

    test "renders default page with no useragent defined", %{conn: conn} do
      conn = get conn, "/"
      assert html_response(conn, 200) =~ "Built with ❤ in a garage in Izhevsk, Russia"
      assert html_response(conn, 200) =~ "<span class=\"button-subtitle-text\">for Windows</span>"
    end

    test "renders default page with Linux useragent", %{conn: conn} do
      conn = get useragent(conn, "Mozilla/5.0 (X11, Linux x86_64)"), "/"
      assert html_response(conn, 200) =~ "<span class=\"button-subtitle-text\">for Linux</span>"
    end

    test "renders default page with Android useragent", %{conn: conn} do
      conn = get useragent(conn, "Mozilla/5.0 (Linux; Android 4.0.4)"), "/"
      assert html_response(conn, 200) =~ "<span class=\"button-subtitle-text\">for Android</span>"
    end
  end

  defp create_clients(_) do
    Clients.create_or_update_app(%{app_name: "helio", link: "1", platform_id: "Linux", version: "2.0"})
    Clients.create_or_update_app(%{app_name: "helio", link: "1", platform_id: "Windows", version: "2.0"})
    Clients.create_or_update_app(%{app_name: "helio", link: "1", platform_id: "macOS", version: "2.0"})
    Clients.create_or_update_app(%{app_name: "helio", link: "1", platform_id: "iOS", version: "2.0"})
    Clients.create_or_update_app(%{app_name: "helio", link: "1", platform_id: "Android", version: "2.0"})
    :ok
  end

  defp useragent(conn, agent) do
    conn
      |> recycle
      |> put_req_header("user-agent", agent)
  end
end
