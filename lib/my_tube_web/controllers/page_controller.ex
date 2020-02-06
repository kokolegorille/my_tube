defmodule MyTubeWeb.PageController do
  use MyTubeWeb, :controller

  alias MyTube.{Core, Uploaders}
  alias Core.Event
  alias Uploaders.MediaUploader

  def index(conn, _params) do
    events = Core.list_events(order: :asc)
    render(conn, "index.html", events: events)
  end

  def show(conn, %{"id" => id}) do
    case Core.get_event(id) do
      nil ->
        conn
        |> put_flash(:error, gettext("Event not found."))
        |> redirect(to: Routes.page_path(conn, :index))
      %Event{} = event ->
        render(conn, "show.html", event: event)
    end
  end

  def get_medium(conn, %{"page_id" => id}) do
    case Core.get_event(id) do
      nil ->
        conn
        |> put_flash(:error, gettext("Event not found."))
        |> redirect(to: Routes.page_path(conn, :index))
      %Event{} = event ->
        local_path = MediaUploader.local_path(event)
        # send_download conn, {:file, local_path}, filename: event.medium.file_name
        conn
        |> put_resp_content_type("video/mp4")
        |> send_file(200, local_path)
    end
  end

  def get_thumb(conn, %{"page_id" => id}) do
    case Core.get_event(id) do
      nil ->
        conn
        |> put_flash(:error, gettext("Event not found."))
        |> redirect(to: Routes.page_path(conn, :index))
      %Event{} = event ->
        local_path = MediaUploader.local_path(event, :thumb)
        # send_download conn, {:file, local_path}, filename: MediaUploader.version_file_name(event, :thumb)
        conn
        |> put_resp_content_type("image/png")
        |> send_file(200, local_path)
    end
  end

  def fourohfour(conn, _params) do
    text(conn, "Page not found. Error 404")
  end
end
