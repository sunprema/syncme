defmodule SyncMeWeb.BookingEvent do
  use SyncMeWeb, :live_view

  alias SyncMe.Events
  require Timex

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(selected_date: nil)}
  end

  @impl true
  def handle_params(%{"event_type_id" => event_type_id }, _uri, socket) do
    IO.inspect(event_type_id, label: "Event Type ID received")
    #Check the event_type_id, If its available and active, so that users can book.
    event_type = Events.get_event_type(event_type_id)

    {:noreply,
      socket
      |> assign(event_type: event_type)
      |> assign(partner: event_type.partner)
      |> assign(availabilty_rules: event_type.partner.availability_rules)
    }
  end

  @impl true
  def handle_event("book", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def handle_event("date-selected", %{ "selected_date" => selected_date}, socket ) do
    IO.inspect( "#{selected_date}", label: "Selected Date!")

    case Timex.parse(selected_date, "%Y-%m-%d", :strftime) do
      {:ok, date} ->
        {:noreply, assign(socket, :selected_date, date)}
      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Invalid Date selected")}
    end

  end


  @impl true
  def handle_info({:event_booked, slot}, socket) do
    IO.inspect(" #{inspect(slot)}", label: "Events already booked")
    {:noreply, socket}
  end

  defp format_date_for_display(timex_date_or_datetime) do
    Timex.format!(timex_date_or_datetime, "%B-%A-%Y", :strftime)
  end

end
