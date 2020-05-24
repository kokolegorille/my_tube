defmodule EventComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div><%= @event.title %></div>
    """
  end
end
