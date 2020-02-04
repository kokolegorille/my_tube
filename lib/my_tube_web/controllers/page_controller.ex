defmodule MyTubeWeb.PageController do
  use MyTubeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def fourohfour(conn, _params) do
    text(conn, "Page not found. Error 404")
  end
end
