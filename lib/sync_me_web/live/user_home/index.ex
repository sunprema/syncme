defmodule SyncMeWeb.UserHome.Index do
  use SyncMeWeb, :live_view

  alias SyncMe.Bookings

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> stream(:upcoming_bookings, get_upcoming_meetings(socket.assigns.current_scope))
      }
  end

  @impl true
  def handle_params(unsigned_params, _uri, socket) do
    IO.inspect(unsigned_params)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_booking_by_user", %{"booking_id" => booking_id}, socket) do
    scope = socket.assigns.current_scope
    booking = Bookings.get_booking!(socket.assigns.current_scope, booking_id)
    socket = case Bookings.cancel_booking_by_user(scope, booking) do

      {:ok, _} ->
        socket
        |> put_flash(:info, "Booking cancelled")
        |> redirect(to: ~p"/user/home")
      {:error, _} ->
        socket
        |> put_flash(:error, "Could not cancel Booking")
    end
    {:noreply, socket }
  end

  defp get_upcoming_meetings(scope) do
    Bookings.list_bookings(scope, %{"upcoming" => true})
  end

end
