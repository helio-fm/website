defmodule Web.Router do
  @moduledoc false

  use Web, :router
  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/auth", Web, as: :auth do
    pipe_through :browser
    get "/", AuthPageController, :confirmation, as: :confirmation
    get "/:provider", AuthPageController, :request, as: :request
    get "/:provider/callback", AuthPageController, :callback, as: :callback
    post "/:provider/callback", AuthPageController, :callback, as: :callback
    delete "/logout", AuthPageController, :delete, as: :delete
  end

  scope "/", Web do
    pipe_through :browser

    get "/", HelioClientPageController, :index, as: :root
    get "/translations", TranslationsRedirectController, :index

    get "/:user", UserPageController, :show
  end
end
