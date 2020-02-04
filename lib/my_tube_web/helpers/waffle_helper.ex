defmodule MyTubeWeb.Helpers.WaffleHelper do
  @moduledoc """
  This is the documentation for the Waffle helpers.
  """

  use Phoenix.HTML

  # HELPERS

  # Add a delete checkbox if attachment is present
  # eg, clear_attachment(%Event{} = source, :thumbnail)
  def clear_attachment(source, field) do
    attachment = Map.get(source, field)
    if attachment do
      content_tag(:div, class: "form-group form-check") do
        [
          tag(:input, name: "#{source_name(source)}[clear_#{field}]", type: :checkbox, value: false, class: "form-check-input"),
          content_tag(:label, "Delete current : #{attachment.file_name}", class: "form-check-label")
        ]
      end
    end
  end

  # Returns the underscore string representation of Struct
  # eg, if source is an event -> "event"
  defp source_name(%{__struct__: struct} = _source) do
    struct
    |> to_string
    |> String.split(".")
    |> List.last
    |> Macro.underscore
  end
  defp source_name(_source), do: nil
end
