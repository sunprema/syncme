defmodule SyncMeWeb.BookingEvent do
  use SyncMeWeb, :live_view

  alias SyncMe.Events
  alias SyncMe.Scheduler
  require Timex

  @impl true
  def mount(%{"event_type_id" => event_type_id} = _params, _session, socket) do
    IO.inspect("Event Type ID : #{event_type_id}", label: "INSIDE MOUNT")

    if connected?(socket) do
      SyncMeWeb.Endpoint.subscribe("event_type_id:#{event_type_id}")
    end

    {:ok,
     socket
     |> assign(selected_date: nil)
     |> assign(meeting_start_time: nil)
     |> assign(meeting_end_time: nil)
     |> assign(available_slots: []), layout: false}
  end

  @impl true
  def handle_params(
        %{"event_type_id" => event_type_id, "encodedTimeSelected" => encodedTimeSelected},
        _uri,
        socket
      ) do
    iso_string = URI.decode(encodedTimeSelected)
    {:ok, meeting_start_time, _} = DateTime.from_iso8601(iso_string)
    event_type = Events.get_event_type(event_type_id)
    available_days = get_available_days(event_type.partner.availability_rules)

    {:noreply,
     socket
     |> assign(event_type: event_type)
     |> assign(partner: event_type.partner)
     |> assign(availabilty_rules: event_type.partner.availability_rules)
     |> assign(available_days: available_days)
     |> assign_meeting_times(meeting_start_time, event_type)}
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
    current_scope = Map.get(socket.assigns, :current_scope, nil)

    socket =
      case current_scope do
        nil ->
          IO.inspect("CURRENT SCOPE IS NULL", label: "SAVE BOOKING NULL SCOPE")
          iso_string = DateTime.to_iso8601(socket.assigns.meeting_start_time)
          encodedMeetingStartTime = URI.encode(iso_string)

          socket
          |> redirect(
            to:
              ~p"/book_event/new/login/#{socket.assigns.event_type.id}/#{encodedMeetingStartTime}"
          )

        scope ->
          socket =
            case Scheduler.create_booking(
                   scope,
                   socket.assigns.event_type,
                   socket.assigns.meeting_start_time,
                   socket.assigns.meeting_end_time
                 ) do
              {:ok, booking} ->


                Phoenix.PubSub.broadcast_from(
                  SyncMe.PubSub,
                  self(),
                  "event_type_id:#{socket.assigns.event_type.id}",
                  {:event_booked, socket.assigns.selected_date}
                )

                socket
                |> put_flash(:info, "Meeting is booked. #{booking.id}")
                |> redirect(to: ~p"/user/home")

              {:error, reason} ->
                socket
                |> put_flash(:error, "Meeting cant be booked. #{inspect(reason)}")
            end

          socket
      end

    {:noreply, socket}
  end

  def handle_event("date-selected", %{"selected_date" => selected_date}, socket) do
    IO.inspect("#{selected_date}", label: "Selected Date!")
    partner = socket.assigns.partner
    event_type = socket.assigns.event_type

    case Timex.parse(selected_date, "%Y-%m-%d", :strftime) do
      {:ok, date} ->
        {:noreply,
         socket
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
        %{"meeting_start_time" => meeting_start_time},
        socket
      ) do
    {:ok, meeting_start_time, _} = DateTime.from_iso8601(URI.decode(meeting_start_time))

    {:noreply,
     socket
     |> assign_meeting_times(meeting_start_time, socket.assigns.event_type)
     |> push_patch(to: ~p"/book_event/details/#{socket.assigns.event_type.id}")}
  end

  @impl true
  def handle_event("booking_confirmed", _params, _socket) do
    # Will get the event_type,time_selected,
  end

  @impl true
  def handle_info({:event_booked, selected_date}, socket) do
    partner = socket.assigns.partner

    socket =
      case Date.compare(socket.assigns.selected_date, selected_date) do
        :eq ->
          socket
          |> put_flash(
            :info,
            "One of the available slots is booked now, refreshing remaining slots"
          )
          |> assign(
            available_slots:
              format_available_slots(
                Scheduler.available_slots(
                  partner.id,
                  socket.assigns.selected_date,
                  socket.assigns.event_type.id
                )
              )
          )

        _ ->
          socket
      end

    {:noreply, socket}
  end

  defp format_available_slots(available_slots) do
    Enum.map(available_slots, fn dt -> {dt, Timex.format!(dt, "{h12}:{0m} {am}")} end)
  end

  # Returns a list of days for the calendar component
  defp get_available_days(availability_rules) do
    Enum.map(availability_rules, fn rule -> rule.day_of_week end)
  end

  defp assign_meeting_times(socket, meeting_start_time, event_type) do
    meeting_end_time =
      Timex.add(meeting_start_time, Timex.Duration.from_minutes(event_type.duration_in_minutes))

    socket
    |> assign(
      meeting_start_time: meeting_start_time,
      meeting_end_time: meeting_end_time
    )
  end

  def format_date(date, format) do
    date && Timex.format!(date, format, :strftime)
  end
end
