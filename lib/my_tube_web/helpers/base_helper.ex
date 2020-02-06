defmodule MyTubeWeb.Helpers.BaseHelper do
  @moduledoc """
  This is the documentation for the Base helpers.
  """
  use Phoenix.HTML

  @doc """
  Returns a sorted string from an association collection.
  By default it returns the names joined by comma.
  It's possible to choose the field to use instead of name.

      Example:
      ========
      assoc_to_string(:languages, field: :code)

  """
  def assoc_to_string(collection, opts \\ []) do
    field = opts[:field] || :name
    collection
    |> Enum.map(& Map.get(&1, field))
    |> Enum.sort()
    |> Enum.join(", ")
  end

  @doc """
  Simple HTML Format text content with line breaks.
  This is a port from ruby from this link:
  https://makandracards.com/makandra/52268-when-you-want-to-format-only-line-breaks-you-probably-do-not-want-simple_format
  """
  def format_linebreaks(text) do
    content_tag(:div) do
      text
      |> String.split("\r\n")
      |> Enum.map(& content_tag(:p, &1))
    end
  end
end
