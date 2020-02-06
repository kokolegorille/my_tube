defmodule MyTubeWeb.Admin.EventController do
  use MyTubeWeb, :controller

  alias MyTube.Core
  alias Core.Event

  plug :authenticate

  def index(conn, _params) do
    events = Core.list_events(order: :asc)
    render(conn, "index.html", events: events)
  end

  def show(conn, %{"id" => id}) do
    case Core.get_event(id) do
      nil ->
        conn
        |> put_flash(:error, gettext("Event not found."))
        |> redirect(to: Routes.admin_event_path(conn, :index))
      %Event{} = event ->
        render(conn, "show.html", event: event)
    end
  end

  def new(conn, _params) do
    changeset = Core.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params} = _params) do
    case Core.create_event(conn.assigns.current_user, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, gettext("Event created successfully."))
        |> redirect(to: Routes.admin_event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, gettext("Could not create event."))
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    event = Core.get_event(id)
    changeset = Core.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Core.get_event(id)

    case Core.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, gettext("Event updated successfully."))
        |> redirect(to: Routes.admin_event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, gettext("Could not update event."))
        |> render("edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Core.get_event(id)
    {:ok, _event} = Core.delete_event(event)

    conn
    |> put_flash(:info, gettext("Event deleted successfully."))
    |> redirect(to: Routes.admin_event_path(conn, :index))
  end
end
