defmodule MyTubeWeb.Helpers.WaffleHelper do
  @moduledoc """
  This is the documentation for the Waffle helpers.
  """

  use Phoenix.HTML
  alias MyTube.Uploaders

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

    # MEDIA

    def display_medium(event, version, opts \\ [])
    def display_medium(%{medium: medium} = _event, _version, _opts) when is_nil(medium) do
      # noop
    end
    def display_medium(event, version, opts) do
      path = event
      |> medium_path(version)

      case Path.extname(path) do
        ".mp4" ->
          opts = Keyword.merge([autoplay: true, loop: true,  muted: true], opts)
          content_tag(:video, opts) do
            content_tag(:source, nil, type: "video/mp4", src: path)
          end
        format when format in [".png", "jpg", "jpeg", ".gif"] ->
          img_tag(path, opts)
        other ->
          content_tag(:p, "Unrecognized format #{other}")
      end
    end

    def medium_path(event, version \\ :original) do
      path = if event.medium do
        Uploaders.MediaUploader.url({event.medium.file_name, event}, version)
      end
      if path, do: Path.join("/uploads/", path)
    end
end
