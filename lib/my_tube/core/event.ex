defmodule MyTube.Core.Event do
  @moduledoc """
  The Core Event structure.
  """

  use Ecto.Schema
  import Ecto.Changeset
  use Waffle.Ecto.Schema

  alias MyTube.Uploaders.MediaUploader

  schema "events" do
    field :title, :string
    field :medium, MediaUploader.Type
    field :medium_uuid, :string

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(title)a

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, @required_fields)
    |> ensure_uuid(:medium_uuid)
    |> cast_attachments(attrs, [:medium])
    |> validate_required([:medium | @required_fields])
  end

  defp ensure_uuid(changeset, field) do
    case get_field(changeset, field) do
      nil -> changeset |> put_change(field, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
