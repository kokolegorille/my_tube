defmodule MyTubeWeb.Admin.UserController do
  use MyTubeWeb, :controller

  alias MyTube.Accounts
  alias Accounts.User

  plug :authenticate, [with_role: "Admin"]

  def index(conn, _params) do
    users = Accounts.list_users(order: :asc)
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
    with %User{} = user <- Accounts.get_user(id) do
      render(conn, "show.html", user: user)
    else
      nil ->
        conn
        |> put_flash(:error, gettext("User not found."))
        |> redirect(to: Routes.admin_user_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Accounts.registration_change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User created successfully."))
        |> redirect(to: Routes.admin_user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, gettext("Could not create user."))
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    user_params = if Accounts.is_self_and_last_admin?(conn.assigns.current_user, user) do
      Map.delete(user_params, "roles")
    else
      user_params
    end

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User updated successfully."))
        |> redirect(to: Routes.admin_user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, gettext("Could not update user."))
        |> render("edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    if Accounts.is_self_and_last_admin?(conn.assigns.current_user, user) do
      conn
      |> put_flash(:error, gettext("Could not delete last admin."))
      |> redirect(to: Routes.admin_user_path(conn, :index))
    else
      {:ok, _user} = Accounts.delete_user(user)
      conn
      |> put_flash(:info, gettext("User deleted successfully."))
      |> redirect(to: Routes.admin_user_path(conn, :index))
    end
  end
end
