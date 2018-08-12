defmodule MusehackersWeb.Api.V1.UserView do
  @moduledoc false

  @users_base_url Application.get_env(:musehackers, :users_base_url)
  @images_base_url Application.get_env(:musehackers, :images_base_url)

  use MusehackersWeb, :view
  alias MusehackersWeb.Api.V1.UserView

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
      profile_url: @users_base_url <> user.login,
      avatar: get_avatar_url(user)}
  end

  defp get_avatar_url(user) do
    if user.avatar, do: @images_base_url <> Kernel.inspect(user.avatar), else: nil
  end

end
