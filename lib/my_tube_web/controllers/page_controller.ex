defmodule MyTubeWeb.PageController do
  use MyTubeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
