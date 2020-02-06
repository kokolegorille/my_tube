defmodule MyTubeWeb.SessionController do
  use MyTubeWeb, :controller
  alias MyTubeWeb.Plugs.Auth

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"name" => name, "password" => password}}) do
    case Auth.login_by_name_and_password(conn, name, password) do
      {:ok, conn} ->
        path = get_session(conn, :redirect_url) || Routes.page_path(conn, :index)

        conn
        |> put_session(:redirect_url, nil)
        |> put_flash(:info, gettext("Welcome back!") <> " " <> name)
        |> redirect(to: path)

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, gettext("Invalid name/password combination"))
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Auth.logout()
    |> put_flash(:info, gettext("See You soon!"))
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
