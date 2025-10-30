defmodule SyncMe.Repo.Migrations.UsersEmailOptional do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :email, :citext, null: true
    end
  end
end
