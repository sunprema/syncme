defmodule SyncMe.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :total_amount_charged, :decimal
      add :platform_fee, :decimal
      add :partner_payout_amount, :decimal
      add :referral_payout_amount, :decimal
      add :status, :string
      add :payment_gateway_id, :string
      add :booking_id, references(:bookings, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:user_id])

    create unique_index(:transactions, [:booking_id])
  end
end
