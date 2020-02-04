defmodule MyTubeWeb.Router do
  use MyTubeWeb, :router
  alias MyTubeWeb.Plugs.Locale

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    #
    plug(Locale)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyTubeWeb do
    pipe_through :browser

    get "/", PageController, :index

    scope "/admin", Admin, as: :admin do
      resources("/events", EventController)
    end

    get "/*path", PageController, :fourohfour
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyTubeWeb do
  #   pipe_through :api
  # end
end
