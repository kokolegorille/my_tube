defmodule MyTube.Uploaders.MediaUploader do
  @moduledoc """
  The Media Uploader.
  """

  use Waffle.Definition

  # Include ecto support (requires package waffle_ecto installed):
  use Waffle.Ecto.Definition

  @acl :public_read

  # versions
  @versions [:original, :thumb, :animated]

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
  #   {:ffmpeg, fn(input, output) -> "-i #{input} -f image2 -vframes 1 #{output}" end, :png}
  # end

  # ARGS AS LIST
  #
  def transform(:thumb, _) do
    {:ffmpeg, fn(input, output) -> ["-i", input, "-f", "image2", "-vframes", "1", output] end, :png}
  end

  def transform(:animated, _) do
    {:ffmpeg, fn(input, output) -> "-i #{input} -f gif #{output}" end, :gif}
  end

  # Override the storage directory:
  def storage_dir(version, {_file, scope}) do
    "event/media/#{version}/#{scope.medium_uuid}"
  end

  # Override the storage directory prefix:
  # IMPORTANT!
  def storage_dir_prefix() do
    Path.join to_string(:code.priv_dir(:my_tube)), ["static/", "uploads"]
  end

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
      Path.join(storage_dir_prefix(), ["event/media/#{version}/", medium_uuid])
    end)
  end
  def all_storage_dirs(_event), do: []

  def rm_storage_dirs(event) do
    all_storage_dirs(event)
    |> Enum.each(fn dir ->
      File.rm_rf(dir)
    end)
  end
end
