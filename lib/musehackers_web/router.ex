defmodule MusehackersWeb.Router do
  use MusehackersWeb, :router
  @moduledoc false

  alias MusehackersWeb.AuthController
  alias MusehackersWeb.RegistrationController
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

  scope "/auth" do
    pipe_through [:browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/api/v1" do
    pipe_through :api

    post "/sign_up", RegistrationController, :sign_up

    # restrict unauthenticated access for routes below
    pipe_through :authenticated
    resources "/users", UserController, except: [:new, :edit]
  end

  scope "/" do
    pipe_through :browser

    get "/", PageController, :index
  end
end
