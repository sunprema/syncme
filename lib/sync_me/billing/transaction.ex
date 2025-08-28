defmodule SyncMe.Billing.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :total_amount_charged, :decimal
    field :platform_fee, :decimal
    field :partner_payout_amount, :decimal
    field :referral_payout_amount, :decimal

    field :status, Ecto.Enum,
      values: [
        :succeeded,
        :pending,
        :failed,
        :refunded
      ]

    field :payment_gateway_id, :string
    belongs_to :booking, SyncMe.Bookings.Booking

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :total_amount_charged,
      :platform_fee,
      :partner_payout_amount,
      :referral_payout_amount,
      :status,
      :payment_gateway_id,
      :booking_id
    ])
    |> validate_required([
      :total_amount_charged,
      :platform_fee,
      :partner_payout_amount,
      :referral_payout_amount,
      :status,
      :payment_gateway_id,
      :booking_id
    ])
  end
end
