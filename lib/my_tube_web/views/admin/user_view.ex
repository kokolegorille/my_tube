defmodule MyTubeWeb.Admin.UserView do
  use MyTubeWeb, :view
  alias MyTube.Accounts

  defdelegate is_self_and_last_admin?(current_user, user), to: Accounts

  def user_links(conn, user) do
    current_user = conn.assigns.current_user

    if is_self_and_last_admin?(current_user, user) do
      [
        {gettext("Edit"), to: Routes.admin_user_path(conn, :edit, user)},
      ]
    else
      [
        {gettext("Edit"), to: Routes.admin_user_path(conn, :edit, user)},
        {
          gettext("Delete"),
          to: Routes.admin_user_path(conn, :delete, user),
          method: :delete,
          data: [confirm: gettext("Are you sure?")]
        }
      ]
    end
  end

  def roles_from_mask(mask), do: Accounts.roles_from_mask(mask)

  # returns the list of allowed roles for checkboxes
  def select_roles do
    Enum.map(Accounts.allowed_roles(), & {&1, &1})
  end

  # returns the list of user roles, to be used in multi_checkboxes
  def user_selected_roles(user) do
    roles_from_mask(user.roles_mask)
  end

  # OBJECT MENU
  def render("object_menu.html", %{conn: conn} = _assigns) do
    if is_index?(conn) do
      dropdown(
        title: gettext("Settings"),
        links: [{gettext("New User"), to: Routes.admin_user_path(conn, :new)}],
        class: "text-danger",
        icon: "cog"
      )
    else
      if is_show?(conn) do
        current_user = conn.assigns.current_user
        dropdown(
          title: gettext("Settings"),
          links: user_links(conn, current_user),
          class: "text-danger",
          icon: "cog"
        )
      end
    end
  end

  defp is_index?(%{method: "GET", request_path: "/admin/users"}), do: true
  defp is_index?(_conn), do: false

  defp is_show?(%{method: "GET", path_params: %{"id" => _id}, request_path: request_path}) do
    not String.ends_with?(request_path, "edit")
  end
  defp is_show?(_conn), do: false
end
