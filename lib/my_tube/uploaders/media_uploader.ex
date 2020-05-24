defmodule MyTube.Uploaders.MediaUploader do
  @moduledoc """
  The Media Uploader.
  """

  use Waffle.Definition

  # Include ecto support (requires package waffle_ecto installed):
  use Waffle.Ecto.Definition

  @acl :public_read

  # versions
  # @versions [:original, :thumb, :animated]
  @versions [:original, :thumb]

  @video_extension ~w(.mp4 .mov)

  # Whitelist file extensions:
  # def validate({file, _}) do
  #   ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  # end
  def validate({file, _}) do
    @video_extension
    |> Enum.member?(Path.extname(file.file_name))
  end

  # https://en.wikibooks.org/wiki/FFMPEG_An_Intermediate_Guide/image_sequence

  # ARGS AS STRING
  #
  # def transform(:thumb, _) do
  #   {:ffmpeg, fn(input, output) -> "-i #{input} -f image2 -vframes 1 -y #{output}" end, :png}
  # end

  # ARGS AS LIST
  #
  def transform(:thumb, _) do
    # {:ffmpeg, fn(input, output) -> ["-i", input, "-f", "image2", "-vframes", "1", "-y", output] end, :png}
    :skip
  end

  # def transform(:animated, _) do
  #   # {:ffmpeg, fn(input, output) -> "-i #{input} -f gif -y #{output}" end, :gif}
  #   :skip
  # end

  # Override the storage directory:
  def storage_dir(version, {_file, scope}) do
    "#{version_dir(version)}#{scope.medium_uuid}"
  end

  # Override the storage directory prefix:
  # IMPORTANT!
  # def storage_dir_prefix() do
  #   # Path.join to_string(:code.priv_dir(:my_tube)), ["static/", "uploads"]
  #   "/Users/sqrt/DATA_2020/uploads"
  # end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end
  def default_url(version, _scope) do
    "/images/media/default_#{version}.png"
  end

  # Additional, helper for deletion
  def all_storage_dirs(%{medium_uuid: medium_uuid} = _event) when not is_nil(medium_uuid) do
    @versions
    |> Enum.map(fn version ->
      Path.join(storage_dir_prefix(), [version_dir(version), medium_uuid])
    end)
  end
  def all_storage_dirs(_event), do: []

  def rm_storage_dirs(event) do
    all_storage_dirs(event)
    |> Enum.each(fn dir ->
      File.rm_rf(dir)
    end)
  end

  def version_dir(version), do: "event/media/#{version}/"

  # def local_path(event, version \\ :original) do
  #   path = {event.medium, event}
  #   |> url(version)
  #   |> sanitize_path()

  #   case path do
  #     nil -> nil
  #     path -> Path.join(storage_dir_prefix(), path)
  #   end
  # end

  # # Waffle returns nil path for outside version transformation
  # # => Forge one
  # def local_auto_path(event, version \\ :original) do
  #   Path.join(
  #     local_dir(event, version),
  #     version_file_name(event, version)
  #   )
  # end

  def local_path(event, version \\ :original)
  def local_path(event, :original) do
    path = {event.medium, event}
    |> url(:original)
    |> sanitize_path()

    case path do
      nil -> nil
      path -> Path.join(storage_dir_prefix(), path)
    end
  end
  # Waffle returns nil path for outside version transformation
  # => Forge one
  def local_path(event, version) do
    Path.join(
      local_dir(event, version),
      version_file_name(event, version)
    )
  end

  def version_file_name(event, :thumb) do
    Path.rootname(event.medium.file_name) <> ".png"
  end

  def version_file_name(event, _) do
    event.medium.file_name
  end

  def local_dir(event, version \\ :original) do
    Path.join(
      storage_dir_prefix(),
      storage_dir(version, {nil, event})
    )
  end

  defp sanitize_path(nil), do: nil
  defp sanitize_path(path) do
    path
    |> String.split("?")
    |> List.first
  end
end
