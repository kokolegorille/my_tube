defmodule MyTube.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :citext
      add :email, :citext
      add :password_hash, :string

      # Embed roles
      add :roles_mask, :integer, default: 0

      timestamps(type: :utc_datetime)
    end
    create unique_index(:users, [:name])
    create unique_index(:users, [:email])
  end
end
