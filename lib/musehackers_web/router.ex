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

    # transforms camelCase json keys into elixir's snake_case
    plug ProperCase.Plug.SnakeCaseParams
  end

  pipeline :clients do
    plug Musehackers.Auth.Pipeline
    # credo:disable-for-next-line
    # TODO add some workstation app check?
    # like header api key or so
  end

  pipeline :authenticated do
    plug Musehackers.Auth.Pipeline
  end

  scope "/api", MusehackersWeb.Api, as: :api do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      post "/join", RegistrationController, :sign_up, as: :registration
      post "/login", SessionController, :sign_in, as: :session

      # some stuff for specific client apps
      # e.g. `/api/v1/clients/helio/resources/translations`
      scope "/clients", as: :client do
        pipe_through :clients

        resources "/resources", ClientResourceController, except: [:new, :edit], as: :resource
        resources "/info", ClientAppController, except: [:new, :edit], as: :app_info

        # One-off endpoint to force running a worker to fetch translations
        get "/update-translations", JobsController, :update_translations

        # credo:disable-for-next-line
        # TODO replace that^ with:
        # get "/:app/info", ClientAppController, :get_client_info, as: :info
        # get "/:app/resources/:resource", ClientAppController, :get_client_resource, as: :resource

        # pipe_through :authenticated
        # post "/:app/resources/:resource", ClientAppController, :update_client_resource, as: :resource
        # post "/:app/info", ClientAppController, :update_client_info, as: :info
      end

      # restrict unauthenticated access for routes below
      pipe_through :authenticated

      # a simple authentication check
      get "/session-status", SessionController, :is_authenticated, as: :session_status

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
      post "/relogin", SessionController, :refresh_token, as: :session

      resources "/users", UserController, except: [:new, :edit]
    end
  end

  scope "/", MusehackersWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
end
