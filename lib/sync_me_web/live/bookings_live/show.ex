defmodule SyncMeWeb.BookingView do
  use SyncMeWeb, :live_view

  alias SyncMe.Bookings
  alias SyncMe.Blockchain.Contracts.SyncMeEscrow

  @impl true
  def mount(%{"booking_id" => booking_id}, _session, socket) do
    case Bookings.get_booking!(socket.assigns.current_scope, booking_id) do
      nil ->
        {:ok, socket |> put_flash(:error, "Booking not found")}

      booking ->
        {:ok,
         socket
         |> assign(booking: booking)}
    end
  end

  @impl true
  def handle_params(
        %{"booking_id" => booking_id},
        _uri,
        socket
      ) do
    case Bookings.get_booking!(socket.assigns.current_scope, booking_id) do
      nil ->
        {:noreply, socket |> put_flash(:error, "Booking not found")}

      booking ->
        {:noreply,
         socket
         |> assign(booking: booking)}
    end
  end

  @impl true
  def handle_event("complete_booking", %{"booking_id" => booking_id}, socket) do
    booking = Bookings.get_booking!(socket.assigns.current_scope, booking_id)

    complete_booking_call =
      SyncMe.Blockchain.Contracts.SyncMeEscrow.complete_booking(
        Decimal.to_integer(booking.contract_booking_id)
      )

    hex_code = Ethers.Utils.hex_encode(complete_booking_call.data, include_prefix: false)

    booking_complete_call_data = %{
      "partner_wallet_address" => socket.assigns.current_scope.user.wallet_address,
      "booking_id" => booking.id,
      "to" => SyncMeEscrow.contract_address(),
      "data" => hex_code
    }

    {:noreply,
     socket
     |> push_event("complete_booking_chain", booking_complete_call_data)}
  end

  @impl true
  def handle_event(
        "complete_booking_txhash_event",
        %{"tx_hash" => tx_hash, "booking_id" => booking_id},
        socket
      ) do
    {:reply, %{"info" => "This is great job"},
     socket
     |> put_flash(:info, "Booking is marked as complete for #{booking_id} with hash #{tx_hash}")}
  end
end
