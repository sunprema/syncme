defmodule SyncMe.Repo.Migrations.AlterEventTypes do
  use Ecto.Migration

  def change do
    alter table(:event_types) do
      add :currency, :string
      modify :price, :integer
    end
  end
end
