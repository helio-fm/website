defmodule Api.Router do
  @moduledoc false

  use Api, :router
  require Ueberauth

  pipeline :api do
    plug :accepts, [:v1]
    plug Api.Plugs.APIVersion
    plug Api.Plugs.CamelCaseDecoder
  end

  pipeline :authenticated do
    plug Api.Auth.CheckToken
  end

  scope "/", Api, as: :api do
    pipe_through :api

    # some stuff for specific client apps
    # e.g. `/clients/helio/translations`
    scope "/clients", as: :client do
      get "/:app/info", ClientAppController, :get_client_info, as: :app_info
      get "/:app/:resource_type", ClientAppController, :get_client_resource, as: :resource

      # initialize web authentication via, say, Github:
      # creates a new Clients.AuthSession and returns its id, secret key and browser url
      post "/:app/auth", AuthSessionController, :init_client_auth_session, as: :auth_init

      # requires auth id and secret key received using a method above,
      # returns 404, if auth with such id and key does not exist
      # returns 204, if auth is still in progress and there is no token available,
      # returns 410, if auth was completed with an error (or is stale), then deletes auth request
      # returns 200 with token, if auth completed successfully, then deletes the auth request
      post "/:app/auth/check", AuthSessionController, :finalise_client_auth_session, as: :auth_finalise

      pipe_through :authenticated
      post "/:app/:resource/update", ClientAppController, :update_client_resource, as: :resource_update
    end

    # restrict unauthenticated access for routes below
    pipe_through :authenticated

    scope "/my", as: :user do
      # returns the logged in user's profile, including all active sessions
      # the summary of available resources (similar to client app info, not including resource data),
      # and the summary of existing projects (identical to get /vcs/projects)
      get "/profile", UserController, :get_current_user, as: :profile

      scope "/sessions" do
        # this endpoint provides a kind of a sliding session:
        # first, it checks for a token, that is
        #   1) valid and unexpired,
        #   2) present in active sessions for a given device id;
        # if passed, it issues a new token and saves it in the related active session
        # (there can be only one session per user and device id),
        # so that if user runs the app, say, at least once a week, his session won't expire
        # (and if the token is compromised/stolen, the user's session won't be prolonged,
        # eventually forcing him to re-login, and thus invalidating attacker's session);
        # and, although re-issuing a token is stateful, authentication is still stateless and fast
        post "/current/update", SessionController, :refresh_token, as: :current_session

        # a simple authentication check (mainly used in tests)
        get "/current/status", SessionController, :is_authenticated, as: :current_session

        # invalidate custom session (also to be used as logout endpoint)
        delete "/:device_id", SessionController, :delete, as: :session
      end

      # e.g. /my/arpeggiators/arp-name or /my/scripts/script-name
      scope "/resources" do
        get "/:type/:name", UserResourceController, :show, as: :resource
        put "/:type/:name", UserResourceController, :create_or_update, as: :resource
        delete "/:type/:name", UserResourceController, :delete, as: :resource
      end

      scope "/projects" do
        # identical to `projects` array in `get /my` response
        get "/", ProjectController, :index
        scope "/:project_id" do
          # includes summary for all revisions
          get "/", ProjectController, :summary
          put "/", ProjectController, :create_or_update
          delete "/", ProjectController, :delete

          scope "/revisions/:revision_id" do
            # put and get full data for any revision
            get "/", RevisionController, :show
            put "/", RevisionController, :create
          end
        end
      end
    end
  end
end
