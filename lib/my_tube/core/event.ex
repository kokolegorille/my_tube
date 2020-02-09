defmodule MyTube.Core.Event do
  @moduledoc """
  The Core Event structure.
  """

  use Ecto.Schema
  import Ecto.Changeset
  use Waffle.Ecto.Schema

  alias MyTube.{Accounts, Uploaders}
  alias Accounts.User
  alias Uploaders.MediaUploader

  schema "events" do
    # Belongs_to
    belongs_to(:creator, User, foreign_key: :user_id, on_replace: :delete)

    many_to_many :liked_users, User, join_through: "likes", on_replace: :delete
    many_to_many :viewed_users, User, join_through: "views", on_replace: :delete

    # Counter cache
    field :likes_count, :integer
    field :views_count, :integer

    field :title, :string
    field :description, :binary

    # Waffle
    field :medium, MediaUploader.Type
    field :medium_uuid, :string

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(title description)a

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, @required_fields)
    |> ensure_uuid(:medium_uuid)
    |> cast_attachments(attrs, [:medium])
    |> assoc_constraint(:creator)
    |> validate_required([:medium | @required_fields])
  end

  defp ensure_uuid(changeset, field) do
    case get_field(changeset, field) do
      nil -> changeset |> put_change(field, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
