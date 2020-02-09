defmodule MyTube.Repo.Migrations.CreateViews do
  use Ecto.Migration

  def change do
    create table(:views, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :event_id, references(:events, on_delete: :delete_all)
    end
  end
end
