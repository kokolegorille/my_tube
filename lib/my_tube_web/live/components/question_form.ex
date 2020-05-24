defmodule MyTubeWeb.Live.Components.QuestionForm do
  use Phoenix.LiveComponent
  alias MyTubeWeb.PageView

  def render(assigns) do
    IO.puts "Initial render #{inspect assigns}"

    PageView.render("live_question_form.html", assigns)
  end

  def update(assigns, socket) do
    IO.puts "Updating #{inspect assigns}, #{inspect socket.assigns}"

    {:ok, %{socket | assigns: assigns}}
  end

  def handle_event("change", event, socket) do
    %{"question" => %{"content" => content}} = event

    IO.inspect socket.assigns, label: "ASSIGNS"
    IO.inspect event, label: "EVENT"
    IO.inspect content, label: "CONTENT"

    # if socket.assigns.disable_question && String.length(content) > 0 do
    #   send self(), :enable_question
    # end

    # if not socket.assigns.disable_question && String.length(content) == 0 do
    #   send self(), :disable_question
    # end

    if socket.assigns.question_data.disable_question && String.length(content) > 0 do
      send self(), %{type: "enable_question"}
    end

    if not socket.assigns.question_data.disable_question && String.length(content) == 0 do
      send self(), %{type: "disable_question"}
    end

    {:noreply, socket}
  end

  def handle_event(type, event, socket) do
    IO.inspect {type, event}, label: "FROM QF COMPONENT"
    %{"question" => payload} = event
    send self(), %{type: type, payload: payload}
    {:noreply, socket}
  end
end
