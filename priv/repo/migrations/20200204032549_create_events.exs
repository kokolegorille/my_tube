defmodule MyTube.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string
      add :medium, :string
      add :medium_uuid, :string

      timestamps(type: :utc_datetime)
    end
  end
end
