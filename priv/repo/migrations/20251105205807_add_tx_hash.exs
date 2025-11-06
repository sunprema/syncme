defmodule SyncMe.Repo.Migrations.AddTxHash do
  use Ecto.Migration

  def change do
    alter table(:event_types) do
      add :tx_hash, :string
    end

    alter table(:bookings) do
      add :tx_hash, :string
    end
  end
end
