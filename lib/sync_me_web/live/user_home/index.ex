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

  defp get_upcoming_meetings(scope) do
    Bookings.list_bookings(scope, %{"upcoming" => true})
  end

end
