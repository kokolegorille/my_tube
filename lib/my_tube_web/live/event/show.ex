defmodule MyTubeWeb.Live.Event.Show do
  use Phoenix.LiveView
  require Logger

  alias MyTube.{Accounts, Core, Liking, Viewing, Repo}
  alias MyTubeWeb.PageView

  def render(assigns) do
    Logger.info("ASSIGNS #{inspect assigns}")
    PageView.render("live_show.html", assigns)
  end

  def mount(%{"id" => id} = _params, %{"user_id" => user_id} = session, socket) do
    Logger.info("MOUNT #{inspect(self())}")

    user = get_user_with_preload(user_id)
    event = Core.get_event id

    event = if user do
      # Increment views counter and notify
      case Viewing.view(user, event) do
        :error -> event
        {:ok, _user} ->
          event = Core.get_event(id)
          Phoenix.PubSub.broadcast(
            MyTube.PubSub,
            "event:#{event.id}",
            %{type: "event_viewed", views_count: event.views_count}
          )
          event
      end
    else
      event
    end

    like_status = user.liked_events
    |> Enum.map(& &1.id)
    |> Enum.member?(event.id)

    if connected?(socket) do
      subscribe_to_event("event:#{event.id}")
    end

    socket = socket
    |> assign(:event, event)
    |> assign(:likes_count, event.likes_count)
    |> assign(:views_count, event.views_count)
    |> assign(user_id: session["user_id"])
    |> assign(like_status: like_status)
    |> assign(event_id: id)

    {:ok, socket}
  end
  def mount(%{"id" => id} = _params, _session, socket) do
    event = Core.get_event id

    socket = socket
    |> assign(:event, event)
    |> assign(:likes_count, event.likes_count)
    |> assign(:views_count, event.views_count)
    |> assign(user_id: nil)
    |> assign(like_status: false)
    |> assign(event_id: event.id)

    {:ok, socket}
  end

  def handle_event("incr", _event, socket) do
    Logger.info("RENDER #{inspect(self())}")

    %{event_id: event_id, user_id: user_id} = socket.assigns

    user = get_user_with_preload(user_id)
    event = Core.get_event event_id

    Liking.toggle_like(user, event)
    |> IO.inspect(label: "LIKE RESULT")

    event = Core.get_event event_id

    # Do not send message to self with broadcast_from
    Phoenix.PubSub.broadcast_from(
      MyTube.PubSub,
      self(),
      "event:#{event.id}",
      %{type: "event_liked", likes_count: event.likes_count, user_id: user_id}
    )

    socket = socket
    |> update(:likes_count, fn _ -> event.likes_count end)
    |> update(:like_status, &(not &1))

    {:noreply, socket}
  end

  def handle_info(%{type: "event_liked"} = message, socket) do
    IO.inspect message, label: "MESSAGE RECEIVED"

    user_id = socket.assigns.user_id

    socket = if message.user_id == user_id do
      update(socket, :like_status, &(not &1))
    else
      socket
    end
    |> assign(:likes_count, message.likes_count)

    {:noreply, socket}
  end

  def handle_info(%{type: "event_viewed", views_count: views_count} = _message, socket) do
    socket = assign(socket, :views_count, views_count)
    {:noreply, socket}
  end

  def handle_info(message, socket) do
    Logger.info("Unmatched message #{inspect(message)}")
    {:noreply, socket}
  end

  defp subscribe_to_event(topic) do
    Phoenix.PubSub.subscribe(MyTube.PubSub, topic)
  end

  defp get_user_with_preload(user_id) do
    user_id
    |> Accounts.get_user
    |> Repo.preload(:liked_events)
  end
end
