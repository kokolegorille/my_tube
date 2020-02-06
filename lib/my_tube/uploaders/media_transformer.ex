defmodule MyTube.Uploaders.MediaTransformer do
  @moduledoc """
  The Media Transformer.
  """

  alias MyTube.Uploaders.MediaUploader

  @ffmpeg "ffmpeg"

  # iex> e = Core.get_event 1
  # iex> Uploaders.MediaTransformer.create_thumb e
  # {:ok, "/Users/sqrt/DATA_2020/uploads/event/media/thumb/03496b6d-78eb-445b-988f-011c7e62b524"}
  # iex> Uploaders.MediaTransformer.create_thumb e
  # {:error, "file exists"}
  # iex> Uploaders.MediaTransformer.create_thumb e, override: true
  # {:ok, "/Users/sqrt/DATA_2020/uploads/event/media/thumb/03496b6d-78eb-445b-988f-011c7e62b524"}

  def create_thumb(event, opts \\ []) do
    ensure_executable_exists!(@ffmpeg)
    override = opts[:override] || false

    tp = MediaUploader.local_dir(event, :thumb)

    if not File.exists?(tp), do: File.mkdir_p(tp)

    thumb_name = Path.join(tp, Path.rootname(event.medium.file_name) <> ".png")

    case {File.exists?(thumb_name), override} do
      {true, false} ->
        {:error, "file exists"}
      _ ->
        case System.cmd(@ffmpeg, args_list(event, thumb_name), stderr_to_stdout: true) do
          {_, 0} -> {:ok, thumb_name}
          {error_message, _exit_code} -> {:error, error_message}
        end
    end
  end

  defp args_list(event, thumb_name) do
    # -y flag will override file if exists
    ["-i", MediaUploader.local_path(event), "-f", "image2", "-vframes", "1", "-y", thumb_name]
  end

  defp ensure_executable_exists!(program) do
    unless System.find_executable(program) do
      raise "#{program} does not exists"
    end
  end
end
