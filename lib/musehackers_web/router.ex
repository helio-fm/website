defmodule MusehackersWeb.Router do
  use MusehackersWeb, :router
  @moduledoc false

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

  scope "/api/v1", MusehackersWeb.Api.V1, as: :api_v1 do
    pipe_through :api

    post "/join", RegistrationController, :sign_up
    post "/login", SessionController, :sign_in

    # restrict unauthenticated access for routes below
    pipe_through :authenticated

    # this endpoint provides a kind of a sliding session:
    # first, it checks for a token, that is
    #   1) valid and unexpired,
    #   2) present in active_sessions for a given device id;
    # if passed, it issues a new token and saves it a related active session
    # (there can be only one session per user and device id),
    # so that if user runs the app, say, at least once a week, his session won't expire
    # (and if the token is compromised/stolen, the user's session won't be prolonged,
    # eventually forcing him to re-login, and thus invalidating attacker's session);
    # and, although re-issuing a token is stateful, authentication is still stateless and fast
    post "/relogin", SessionController, :refresh_token

    resources "/users", UserController, except: [:new, :edit]
  end

  scope "/", MusehackersWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
end
