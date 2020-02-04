defmodule MyTubeWeb.LayoutView do
  use MyTubeWeb, :view

  def flash_class(conn) do
    if conn.assigns[:hide_container], do: "container", else: nil
  end

  def links(conn, opts \\ []) do
    class = opts[:class] || "nav-link"
    [
      link(
        gettext("Home"),
        to: Routes.page_path(conn, :index),
        class: class
      )
    ]
  end
end
