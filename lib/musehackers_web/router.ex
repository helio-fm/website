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
    plug :accepts, ["json"] # ["json", "application/octet-stream"]
    # transforms camelCase json keys into elixir's snake_case
    plug Musehackers.Json.CamelCaseDecoder
  end

  pipeline :clients do
    plug Musehackers.Auth.CheckClient
  end

  pipeline :authenticated do
    plug Musehackers.Auth.CheckToken
  end

  scope "/api", MusehackersWeb.Api, as: :api do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      post "/join", RegistrationController, :sign_up, as: :signup
      post "/login", SessionController, :sign_in, as: :login

      # some stuff for specific client apps
      # e.g. `/api/v1/clients/helio/resources/translations`
      scope "/client", as: :client do
        pipe_through :clients
        get "/:app/info", ClientAppController, :get_client_info, as: :app_info
        get "/:app/:resource", ClientResourceController, :get_client_resource, as: :resource

        pipe_through :authenticated
        post "/:app/:resource/update", ClientResourceController, :update_client_resource, as: :resource_update
        post "/", ClientAppController, :create_or_update, as: :update
        get "/", ClientAppController, :index, as: :list
      end

      # restrict unauthenticated access for routes below
      pipe_through :authenticated

      get "/me", UserController, :get_current_user, as: :user
      resources "/user", UserController, only: [:index, :delete], as: :user

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
      post "/relogin", SessionController, :refresh_token, as: :relogin

      # a simple authentication check (mainly used in tests)
      get "/session-status", SessionController, :is_authenticated, as: :session_status
    end
  end

  scope "/", MusehackersWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
end
