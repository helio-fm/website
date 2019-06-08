defmodule Web.UserPageController do
  @moduledoc false

  use Web, :controller

  alias Db.Accounts
  alias Db.Accounts.User

  import Web
  plug :assign_custom_css, custom_css: "user.css"

  def show(conn, %{"user" => user_login}) do
    case Accounts.get_user_by_login(user_login) do
      %User{} = user ->
        render(conn, "index.html", user: user)
      nil ->
        render(conn, "index.html", user: nil)
    end
  end
end
