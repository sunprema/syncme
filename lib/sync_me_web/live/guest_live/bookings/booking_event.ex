defmodule SyncMeWeb.BookingEvent do
  use SyncMeWeb, :live_view

  alias SyncMe.Events
  alias SyncMe.Scheduler
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
    available_days = get_available_days(event_type.partner.availability_rules)
    {:noreply,
      socket
      |> assign(event_type: event_type)
      |> assign(partner: event_type.partner)
      |> assign(availabilty_rules: event_type.partner.availability_rules)
      |> assign(available_days: available_days )
      |> assign(available_slots: [] )
    }
  end

  @impl true
  def handle_event("book", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def handle_event("date-selected", %{ "selected_date" => selected_date}, socket ) do
    IO.inspect( "#{selected_date}", label: "Selected Date!")
    partner = socket.assigns.partner
    event_type = socket.assigns.event_type
    case Timex.parse(selected_date, "%Y-%m-%d", :strftime) do
      {:ok, date} ->
        {:noreply,
          socket
          |> assign(:selected_date, date)
          |> assign(:available_slots, format_available_slots( Scheduler.available_slots( partner.id, date, event_type.id )) )
        }
      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Invalid Date selected")}
    end

  end


  @impl true
  def handle_event("slot_selected", %{"selected_datetime_slot" => selected_datetime_slot}, socket) do
    IO.inspect("#{selected_datetime_slot}", label: "Selected time slot")
    {:noreply, socket}
  end

  @impl true
  def handle_info({:event_booked, slot}, socket) do
    IO.inspect(" #{inspect(slot)}", label: "Events already booked")
    {:noreply, socket}
  end



  defp format_date_for_display(timex_date_or_datetime) do
    Timex.format!(timex_date_or_datetime, "%a %d", :strftime)
  end

  defp format_available_slots(available_slots) do
    Enum.map( available_slots, fn dt -> { dt, Timex.format!( dt, "{h12}:{0m} {am}") } end )
  end

  # Returns a list of days for the calendar component
  defp get_available_days(availability_rules) do
    Enum.map( availability_rules, fn rule ->  rule.day_of_week end)
  end

end
