defmodule SyncMeWeb.BookingEvent do
  use SyncMeWeb, :live_view

  alias SyncMe.Events
  alias SyncMe.Scheduler
  require Timex

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(selected_date: nil)
     |> assign(time_selected: nil)
     |> assign(available_slots: [])
     |> assign(selected_date_str: "")
     |> assign(meeting_start_time_formatted_str: "Friday, September 12, 2025")}
  end

  @impl true
  def handle_params(%{"event_type_id" => event_type_id}, _uri, socket) do
    IO.inspect(event_type_id, label: "Event Type ID received")
    # Check the event_type_id, If its available and active, so that users can book.
    event_type = Events.get_event_type(event_type_id)
    available_days = get_available_days(event_type.partner.availability_rules)

    {:noreply,
     socket
     |> assign(event_type: event_type)
     |> assign(partner: event_type.partner)
     |> assign(availabilty_rules: event_type.partner.availability_rules)
     |> assign(available_days: available_days)}
  end

  @impl true
  def handle_event("save_booking", _unsigned_params, socket) do
    IO.inspect("Booking is being confirmed")

    Scheduler.create_booking( socket.assigns.current_scope,
      socket.assigns.event_type,
      socket.assigns.time_selected,
      100.0
      )

    {:noreply,
    socket
    |> put_flash(:info, "Meeting is booked.")
  }
  end

  def handle_event("date-selected", %{"selected_date" => selected_date}, socket) do
    IO.inspect("#{selected_date}", label: "Selected Date!")
    partner = socket.assigns.partner
    event_type = socket.assigns.event_type

    case Timex.parse(selected_date, "%Y-%m-%d", :strftime) do
      {:ok, date} ->
        {:noreply,
         socket
         |> assign(:selected_date_str, selected_date)
         |> assign(:selected_date, date)
         |> assign(
           :available_slots,
           format_available_slots(Scheduler.available_slots(partner.id, date, event_type.id))
         )}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Invalid Date selected")}
    end
  end

  @impl true
  def handle_event(
        "slot_selected",
        %{"selected_datetime_index" => selected_datetime_index},
        socket
      ) do
    IO.inspect("#{selected_datetime_index}", label: "selected_datetime_index")
    available_slots = socket.assigns.available_slots
    time_selected = Enum.at(available_slots, selected_datetime_index)

    {meeting_start_time, _} = time_selected

    meeting_start_time_formatted_str =
      Timex.format!(meeting_start_time, "%A, %B %d, %Y", :strftime)

    IO.inspect("#{inspect(time_selected)} - #{meeting_start_time_formatted_str}",
      label: "time_selected"
    )

    {:noreply,
     socket
     |> assign(:time_selected, time_selected)
     |> assign(meeting_start_time_formatted_str: meeting_start_time_formatted_str)
     |> push_patch(to: ~p"/book_event/details/#{socket.assigns.event_type.id}")}
  end

  @impl true
  def handle_event("booking_confirmed", _params, socket) do
    # Will get the event_type,time_selected,
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
    Enum.map(available_slots, fn dt -> {dt, Timex.format!(dt, "{h12}:{0m} {am}")} end)
  end

  # Returns a list of days for the calendar component
  defp get_available_days(availability_rules) do
    Enum.map(availability_rules, fn rule -> rule.day_of_week end)
  end
end
