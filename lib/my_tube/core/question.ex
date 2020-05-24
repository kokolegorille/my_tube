defmodule MyTube.Core.Question do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :content, :binary
  end

  @required_fields ~w(content)a

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
