defmodule SyncMe.Repo.Migrations.AddBookingStatuses do
  use Ecto.Migration

  def up do
    execute "INSERT INTO booking_statuses (value) VALUES ('confirmed'), ('cancelled_by_guest'), ('cancelled_by_partner')"
  end

  def down do
    execute "DELETE FROM booking_statuses WHERE value IN ('confirmed', 'cancelled_by_guest', 'cancelled_by_partner')"
  end
end
