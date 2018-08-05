defmodule MusehackersWeb.Api.V1.UserView do
  use MusehackersWeb, :view
  alias MusehackersWeb.Api.V1.UserView
  @moduledoc false

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{login: user.login,
      email: user.email,
      name: user.name,
      avatar: Application.get_env(:musehackers, :images_base_url) <> Kernel.inspect(user.avatar)}
  end
end
