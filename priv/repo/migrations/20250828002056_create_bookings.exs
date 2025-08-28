defmodule SyncMe.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_time, :utc_datetime
      add :end_time, :utc_datetime
      add :status, :string
      add :video_conference_link, :string
      add :price_at_booking, :decimal
      add :duration_at_booking, :integer
      add :partner_id, references(:partners, on_delete: :nothing, type: :binary_id)
      add :guest_user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :event_type_id, references(:event_types, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:bookings, [:user_id])

    create index(:bookings, [:partner_id])
    create index(:bookings, [:guest_user_id])
    create index(:bookings, [:event_type_id])
  end
end
