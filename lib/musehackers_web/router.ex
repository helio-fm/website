defmodule MusehackersWeb.Router do
  use MusehackersWeb, :router

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

  scope "/auth", MusehackersWeb do
    pipe_through [:browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/api/v1", MusehackersWeb do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
  end

  scope "/", MusehackersWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

end
