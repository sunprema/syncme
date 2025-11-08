defmodule SyncMe.Repo.Migrations.AddChainIds do
  use Ecto.Migration

  def change do
    alter table(:event_types) do
      add :contract_event_id, :decimal, precision: 78, scale: 0
      add :chain_id, :string
    end

    alter table(:bookings) do
      add :guest_email, :string
      add :guest_name, :string
      add :contract_booking_id, :decimal, precision: 78, scale: 0
      add :chain_id, :string
    end
  end
end
