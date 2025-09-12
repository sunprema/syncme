# lib/sync_me_web/live/booking_completion_live.ex (New File)
defmodule SyncMeWeb.BookingCompletionLive do
  use SyncMeWeb, :live_view

  alias SyncMe.Scheduler
  alias SyncMe.Events

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :booking, nil)}
  end

  @impl true
  def handle_params(%{"session_id" => session_id}, _uri, socket) do
    # Logged in user
    scope = socket.assigns.current_scope

    with {:ok, session} <- Stripe.Checkout.Session.retrieve(session_id),
         "paid" <- session.payment_status,
         %{"event_type_id" => event_type_id, "meeting_start_time" => start_time_iso} <-
           session.metadata do
      event_type = Events.get_event_type(event_type_id)
      {:ok, meeting_start_time, _} = DateTime.from_iso8601(start_time_iso)

      meeting_end_time =
        Timex.add(meeting_start_time, Timex.Duration.from_minutes(event_type.duration_in_minutes))

      case Scheduler.create_booking(scope, event_type, meeting_start_time, meeting_end_time) do
        {:ok, booking} ->
          # Broadcast that a slot has been booked
          Phoenix.PubSub.broadcast(
            SyncMe.PubSub,
            "event_type_id:#{event_type.id}",
            {:event_booked, booking.start_time}
          )

          {:noreply,
           socket
           |> assign(:booking, booking)
           |> put_flash(:info, "Your meeting is confirmed!")}

        {:error, _reason} ->
          # This can happen if the slot was taken while user was paying
          {:noreply,
           put_flash(socket, :error, "Sorry, this time slot was booked while you were paying.")}
      end
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "There was a problem confirming your payment.")
         |> redirect(to: ~p"/")}
    end
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
