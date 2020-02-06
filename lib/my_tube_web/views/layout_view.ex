defmodule MyTubeWeb.LayoutView do
  use MyTubeWeb, :view

  alias MyTube.Accounts

  def flash_class(conn) do
    if conn.assigns[:hide_container], do: "container", else: nil
  end

  def links(conn, current_user, opts \\ [])
  def links(_conn, nil, _opts), do: []
  def links(conn, current_user, opts) do
    class = opts[:class] || "nav-link"

    result = [
      link(
        gettext("Events"),
        to: Routes.admin_event_path(conn, :index),
        class: class
      )
    ]

    if Accounts.has_role?(current_user, "Admin") do
      [
        link(
          gettext("Users"),
          to: Routes.admin_user_path(conn, :index),
          class: class
        ) | result
      ]
    else
      result
    end
  end

  def right_links(conn, current_user_or_nil, opts \\ []) do
    [
      sign_helper(conn, current_user_or_nil, opts),
      langswitch(lang_params())
    ]
  end

  defp sign_helper(conn, nil, opts) do
    class = opts[:class] || "nav-link"
    link(
      to: Routes.session_path(conn, :new),
      class: class,
      title: gettext("Signin")
    ) do
      fa("sign-in")
    end
  end
  defp sign_helper(conn, current_user, opts) do
    class = opts[:class] || "nav-link"
    link(
      to: Routes.session_path(conn, :delete, current_user),
      method: "delete",
      title: "connected as #{current_user.name}, #{gettext("Signout")}",
      class: class
    ) do
      fa("sign-out")
    end
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
