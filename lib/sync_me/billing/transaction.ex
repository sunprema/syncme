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
    field :booking_id, :binary_id
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs, user_scope) do
    transaction
    |> cast(attrs, [
      :total_amount_charged,
      :platform_fee,
      :partner_payout_amount,
      :referral_payout_amount,
      :status,
      :payment_gateway_id
    ])
    |> validate_required([
      :total_amount_charged,
      :platform_fee,
      :partner_payout_amount,
      :referral_payout_amount,
      :status,
      :payment_gateway_id
    ])
    |> put_change(:user_id, user_scope.user.id)
  end
end
