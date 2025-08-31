defmodule SyncMeWeb.BookingsLive.Index do
  use SyncMeWeb, :live_view
  alias SyncMe.Bookings

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :upcoming, _params) do
      filters = %{"upcoming" => true }
      bookings = Bookings.list_bookings(socket.assigns.current_scope, filters)

      socket
      |> stream(:bookings, bookings)
  end

  defp apply_action(socket, _, params) do

      apply_action(socket, :upcoming, params)

  end


end
