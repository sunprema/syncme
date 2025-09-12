defmodule SyncMeWeb.BookingView do
  use SyncMeWeb, :live_view

  alias SyncMe.Bookings

  @impl true
  def mount(%{"booking_id" => booking_id }, _session, socket) do

    case Bookings.get_booking!(socket.assigns.current_scope, booking_id) do
      nil ->
        {:ok , socket |> put_flash(:error, "Booking not found")}
      booking ->
        {:ok,
        socket
        |> assign(booking: booking)
      }
    end
  end

  @impl true
  def handle_params(
    %{"booking_id" => booking_id}, _uri, socket) do
    case Bookings.get_booking!(socket.assigns.current_scope, booking_id) do
      nil ->
        {:noreply , socket |> put_flash(:error, "Booking not found")}
      booking ->
        {:noreply,
        socket
        |> assign(booking: booking)
      }
    end
    end

end
