# lib/sync_me/payments.ex (New File)
defmodule SyncMe.Payments do
  alias SyncMe.Events.EventType

  @application_fee_percent 0.10
  @doc """
  Creates a Stripe Checkout session for a booking.
  """
  def create_checkout_session(
        %EventType{} = event_type,
        meeting_start_time,
        success_url,
        cancel_url
      ) do
    partner = event_type.partner

    # Ensure the partner has a connected Stripe account
    if stripe_account_id = partner.stripe_account_id do
      # Calculate your platform's fee (e.g., 10%)
      application_fee = round(event_type.price * @application_fee_percent)

      params = %{
        line_items: [
          %{
            price_data: %{
              currency: event_type.currency || "usd",
              product_data: %{
                name: "Booking: #{event_type.name}"
              },
              unit_amount: event_type.price
            },
            quantity: 1
          }
        ],
        mode: "payment",
        success_url: success_url,
        cancel_url: cancel_url,
        # This is the key for Stripe Connect: direct the payment to the partner
        payment_intent_data: %{
          application_fee_amount: application_fee,
          transfer_data: %{
            destination: stripe_account_id
          }
        },
        # Pass metadata to identify the booking after successful payment
        metadata: %{
          event_type_id: event_type.id,
          meeting_start_time: DateTime.to_iso8601(meeting_start_time)
        }
      }

      Stripe.Checkout.Session.create(params)
    else
      {:error, :partner_not_connected_to_stripe}
    end
  end
end
