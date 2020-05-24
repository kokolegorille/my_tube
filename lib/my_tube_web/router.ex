defmodule MyTubeWeb.Router do
  use MyTubeWeb, :router
  alias MyTubeWeb.Plugs.{Auth, Locale}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    # plug :fetch_flash
    # plug Phoenix.LiveView.Flash
    plug :fetch_live_flash
    plug :put_root_layout, {MyTubeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    #
    plug(Auth)
    plug(Locale)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyTubeWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources("/sessions", SessionController, only: [:new, :create, :delete])

    # REPLACE SHOW BY LIVEVIEW
    # resources("/events", PageController, only: [:show]) do

    resources("/events", PageController, only: []) do
      get "/get_medium", PageController, :get_medium
      get "/get_thumb", PageController, :get_thumb
    end

    # Live view
    live "/events/:id", Live.Event.Show

    scope "/admin", Admin, as: :admin do
      resources("/users", UserController)
      resources("/events", EventController)
    end

    get "/*path", PageController, :fourohfour
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyTubeWeb do
  #   pipe_through :api
  # end
end
