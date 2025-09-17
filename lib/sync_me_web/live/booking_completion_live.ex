# lib/sync_me_web/live/booking_completion_live.ex (New File)
defmodule SyncMeWeb.BookingCompletionLive do
  use SyncMeWeb, :live_view

  alias SyncMe.Bookings
  alias SyncMe.Events

  @impl true
  def mount(params, session, socket) do
    IO.inspect("MOUNT IS CALLED with params #{inspect(params)}", label: __MODULE__)

    if connected?(socket) do
      handle_stripe_callback(params, session, socket)
    else
      {:ok,
       socket
       |> assign(booking: nil)}
    end
  end

  defp handle_stripe_callback(%{"session_id" => session_id}, _session, socket) do
    scope = socket.assigns.current_scope

    IO.inspect("handle_params IS CALLED with session_id #{inspect(session_id)}",
      label: __MODULE__
    )

    with {:ok, session} <- Stripe.Checkout.Session.retrieve(session_id),
         "paid" <- session.payment_status,
         %{"event_type_id" => event_type_id, "meeting_start_time" => start_time_iso} <-
           session.metadata do
      event_type = Events.get_event_type(event_type_id)
      booking_attrs = %{"event_type_id" => event_type.id, "start_time" => start_time_iso}
      IO.inspect("PAYEMENT SUCCESS", label: "BOOKING COMPLETION LIVE")

      case Bookings.create_booking(scope, booking_attrs) do
        {:ok, booking} ->
          # Broadcast that a slot has been booked
          IO.inspect("BOOKING SUCCESS: #{inspect(booking)}", label: "BOOKING COMPLETION LIVE")

          Phoenix.PubSub.broadcast(
            SyncMe.PubSub,
            "event_type_id:#{event_type.id}",
            {:event_booked, booking.start_time}
          )

          {:ok,
           socket
           |> assign(:booking, booking)
           |> put_flash(:info, "Your meeting is confirmed!")}

        {:error, reason} ->
          # This can happen if the slot was taken while user was paying
          IO.inspect("FAILED #{inspect(reason)}", label: __MODULE__)

          {:ok,
           put_flash(socket, :error, "Sorry, this time slot was booked while you were paying.")}
      end
    else
      _ ->
        IO.inspect("PAYEMENT FAILURE", label: "BOOKING COMPLETION LIVE")

        {:ok,
         socket
         |> put_flash(:error, "There was a problem confirming your payment.")
         |> redirect(to: ~p"/")}
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Booking Confirmation</h1>
      <%= if @booking do %>
        <p>Your meeting has been successfully booked!</p>
        <p>Event: {@booking.event_type.name}</p>
        <p>Time: {@booking.start_time}</p>
      <% else %>
        <p>Verifying your booking...</p>
      <% end %>
      <.link href={~p"/user/home"}>Back to Home</.link>
    </div>
    """
  end
end
