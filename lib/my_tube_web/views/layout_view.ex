defmodule MyTubeWeb.LayoutView do
  use MyTubeWeb, :view

  def flash_class(conn) do
    if conn.assigns[:hide_container], do: "container", else: nil
  end

  def links(conn, opts \\ []) do
    class = opts[:class] || "nav-link"
    [
      # link(
      #   gettext("Home"),
      #   to: Routes.page_path(conn, :index),
      #   class: class
      # ),
      link(
        gettext("Events"),
        to: Routes.admin_event_path(conn, :index),
        class: class
      )
    ]
  end

  def right_links(_conn, _opts \\ []) do
    [
      langswitch(lang_params())
    ]
  end

  # Langswitch
  defp lang_params do
    selected = get_selected()
    [
      links: lang_links(selected),
      selected: selected
    ]
  end

  # Returns a list of lang links with selected as first element!
  defp lang_links(selected) do
    MyTubeWeb.Gettext
    |> Gettext.known_locales()
    |> Enum.sort_by(fn locale -> locale != selected end)
    |> Enum.map(fn locale -> {locale, to: "?locale=#{locale}"} end)
  end

  defp get_selected, do: Gettext.get_locale(MyTubeWeb.Gettext)
end
