defmodule SyncMe.BillingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SyncMe.Billing` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        partner_payout_amount: "120.5",
        payment_gateway_id: "some payment_gateway_id",
        platform_fee: "120.5",
        referral_payout_amount: "120.5",
        status: "some status",
        total_amount_charged: "120.5"
      })

    case SyncMe.Billing.create_transaction(scope, attrs) do

      {:error, _booking_not_authorized} ->
        raise "Booking not authorized"

      end
  end
end
