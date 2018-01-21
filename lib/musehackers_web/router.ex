defmodule MusehackersWeb.Router do
  use MusehackersWeb, :router
  @moduledoc false

  alias MusehackersWeb.RegistrationController
  alias MusehackersWeb.SessionController
  alias MusehackersWeb.UserController
  alias MusehackersWeb.PageController

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    # plug :accepts, ["json", "application/octet-stream"]
  end

  pipeline :authenticated do
    plug Musehackers.Guardian.AuthPipeline
  end

  scope "/api/v1" do
    pipe_through :api

    post "/join", RegistrationController, :sign_up
    post "/login", SessionController, :sign_in

    # restrict unauthenticated access for routes below
    pipe_through :authenticated
    # should have a token that is 1) valid, 2) present in active_sessions for given device id
    post "/relogin", SessionController, :refresh_token

    resources "/users", UserController, except: [:new, :edit]
  end

  scope "/" do
    pipe_through :browser

    get "/", PageController, :index
  end
end
