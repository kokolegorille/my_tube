defmodule MyTube.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :title, :string
      add :description, :binary
      add :medium, :string
      add :medium_uuid, :string

      timestamps(type: :utc_datetime)
    end
  end
end
