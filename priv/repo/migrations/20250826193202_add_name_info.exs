defmodule SyncMe.Repo.Migrations.AddNameInfo do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :first_name, :string, null: true
      add :last_name, :string, null: true
    end
  end

  def down do
    alter table(:users) do
      remove :first_name
      remove :last_name
    end
  end
end
