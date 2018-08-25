defmodule Api.UserView do
  @moduledoc false

  @users_base_url Application.get_env(:musehackers, :users_base_url)
  @images_base_url Application.get_env(:musehackers, :images_base_url)

  use Api, :view
  alias Api.UserView

  def render("index.v1.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.v1.json")}
  end

  def render("show.v1.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.v1.json")}
  end

  def render("user.v1.json", %{user: user}) do
    %{login: user.login,
      email: user.email,
      name: user.name,
      profile_url: @users_base_url <> user.login,
      avatar: get_avatar_url(user)}
  end

  defp get_avatar_url(user) do
    if user.avatar, do: @images_base_url <> Kernel.inspect(user.avatar), else: nil
  end

end
