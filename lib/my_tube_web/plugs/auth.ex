defmodule MyTubeWeb.Plugs.Auth do
  @moduledoc false
  import Plug.Conn
  import Phoenix.Controller
  alias MyTubeWeb.Router.Helpers, as: Routes
  alias MyTube.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end

  def login_by_name_and_password(conn, name, password) do
    case Accounts.authenticate(name, password) do
      {:ok, user} -> {:ok, login(conn, user)}
      {:error, :unauthorized} -> {:error, :unauthorized, conn}
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  # TO KEEP FLASH MESSAGE ON LOGOUT... use clear_session!
  # def logout(conn), do: configure_session(conn, drop: true)
  def logout(conn), do: clear_session(conn)

  # with_role: role_as_string
  # check if user exists and has the role
  def authenticate(conn, opts) do
    with_role = opts[:with_role]

    with %Accounts.User{} = current_user <- conn.assigns.current_user,
      true <- is_nil(with_role) || Accounts.has_role?(current_user, with_role)
    do
      conn
    else
      nil ->
        conn
        |> put_session(:redirect_url, conn.request_path)
        |> maybe_put_flash_error("You must be logged in to access that page")
        |> redirect(to: Routes.session_path(conn, :new))
        |> halt()
      _ ->
        conn
        |> put_session(:redirect_url, conn.request_path)
        |> maybe_put_flash_error("You are not authorized to access that page")
        |> redirect(to: Routes.session_path(conn, :new))
        |> halt()
    end
  end

  # Don not put an error message when redirecting to root
  defp maybe_put_flash_error(conn, message) do
    if conn.request_path == "/" do
      conn
    else
      put_flash(conn, :error, message)
    end
  end
end
