defmodule Web.UserPageControllerTest do
  use Web.ConnCase

  alias Db.Accounts

  describe "renders user page" do
    setup [:create_user]

    test "renders stub page for existing user", %{conn: conn, user: user} do
      conn = get conn, user_page_path(conn, :show, user.login)
      assert html_response(conn, 200) =~ "Not implemented"
    end

    test "renders error for non-existing user", %{conn: conn, user: _user} do
      conn = get conn, user_page_path(conn, :show, "unknown")
      assert html_response(conn, 200) =~ "Not today"
    end
  end

  @user_attrs %{
    login: "tester",
    email: "test@helio.fm",
    name: "name",
    password: "some password"
  }

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    {:ok, user: user}
  end
end
