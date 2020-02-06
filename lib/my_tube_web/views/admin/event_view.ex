defmodule MyTubeWeb.Admin.EventView do
  use MyTubeWeb, :view

  # OBJECT MENU
  def render("object_menu.html", %{conn: conn} = _assigns) do
    if is_index?(conn) do
      dropdown(
        title: gettext("Settings"),
        links: [{gettext("New Event"), to: Routes.admin_event_path(conn, :new)}],
        class: "text-danger",
        icon: "cog"
      )
    else
      if is_show?(conn) do
        event = conn.assigns.event
        dropdown(
          title: gettext("Settings"),
          links: event_links(conn, event),
          class: "text-danger",
          icon: "cog"
        )
      end
    end
  end

  def event_links(conn, event) do
    [
      {gettext("Edit"), to: Routes.admin_event_path(conn, :edit, event)},
      {
        gettext("Delete"),
        to: Routes.admin_event_path(conn, :delete, event),
        method: :delete,
        data: [confirm: gettext("Are you sure?")]
      }
    ]
  end

  defp is_index?(%{method: "GET", request_path: "/admin/events"}), do: true
  defp is_index?(_conn), do: false

  defp is_show?(%{method: "GET", path_params: %{"id" => _id}, request_path: request_path}) do
    not String.ends_with?(request_path, "edit")
  end
  defp is_show?(_conn), do: false
end
