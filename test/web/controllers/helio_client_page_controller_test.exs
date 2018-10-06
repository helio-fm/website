defmodule Web.HelioClientPageControllerTest do
  use Web.ConnCase

  alias Db.Clients

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
    Clients.create_or_update_app_version(%{app_name: "helio", link: "1", platform_type: "Linux",
      build_type: "installer", branch: "stable", architecture: "all", version: "2.0"})
    Clients.create_or_update_app_version(%{app_name: "helio", link: "1", platform_type: "Windows",
      build_type: "installer", branch: "stable", architecture: "all", version: "2.0"})
    Clients.create_or_update_app_version(%{app_name: "helio", link: "1", platform_type: "macOS",
      build_type: "installer", branch: "stable", architecture: "all", version: "2.0"})
    Clients.create_or_update_app_version(%{app_name: "helio", link: "1", platform_type: "iOS",
      build_type: "installer", branch: "stable", architecture: "all", version: "2.0"})
    Clients.create_or_update_app_version(%{app_name: "helio", link: "1", platform_type: "Android",
      build_type: "installer", branch: "stable", architecture: "all", version: "2.0"})
    :ok
  end

  defp useragent(conn, agent) do
    conn
      |> recycle
      |> put_req_header("user-agent", agent)
  end
end
