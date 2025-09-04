defmodule SyncMeWeb.AvailabilityLive.Show do
  use SyncMeWeb, :live_view
  alias SyncMe.Availability
  alias SyncMe.Availability.AvailabilityRule
  alias SyncMe.Partners


  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    partner = Partners.get_partner(scope)

    if is_nil(partner) do
      {:ok,
        socket
          |> put_flash(:error, "No partnerships available")
          |> redirect(~p"/partner/signup")
    }
    end

    days = [

      %{day_of_week: 1, enabled: true, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 2, enabled: true, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 3, enabled: true, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 4, enabled: true, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 5, enabled: true, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 6, enabled: false, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 7, enabled: false, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
    ]
    socket =
      socket
      |> assign(:days, days)
      |> assign(partner: partner)
      |> assign(:time_options, generate_time_options())

    {:ok, socket}

  end


  @impl true
  def handle_event("toggle_day", %{"day" => day_str}, socket) do
    day_index = String.to_integer(day_str) - 1

    days =
      socket.assigns.days
      |> List.update_at(day_index, fn day ->
        %{day | enabled: !day.enabled}
      end)

    {:noreply, assign(socket, :days, days)}
  end

  @impl true
  def handle_event("update_time", %{"day" => day_str, "field" => field, "time" => value}, socket) do
    day_index = day_str #String.to_integer(day_str) - 1

    days =
      socket.assigns.days
      |> List.update_at(day_index, fn day ->
        case field do
          "start_time" -> %{day | start_time: parse_time(value)}
          "end_time" -> %{day | end_time: parse_time(value)}
        end
      end)

    {:noreply, assign(socket, :days, days)}
  end

  @impl true
  def handle_event("update_time", params, socket) do

    IO.inspect(params)
    {:noreply, socket}
  end


  @impl true
  def handle_event("save", _params, socket) do

    enabled_rules = Enum.filter(socket.assigns.days, & &1.enabled)
    IO.inspect(enabled_rules)
    Availability.save_availability_rule(socket.assigns.current_scope, enabled_rules)
    {:noreply, socket}
  end

  @impl true
  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end


  defp parse_time(value) do
    case Time.from_iso8601(value <> ":00") do
      {:ok, time} -> time
      {:error, _} -> ~T[09:00:00] # Fallback to default time
    end
  end

  defp day_name(day_of_week) do
    case day_of_week do
      1 -> "Monday"
      2 -> "Tuesday"
      3 -> "Wednesday"
      4 -> "Thursday"
      5 -> "Friday"
      6 -> "Saturday"
      7 -> "Sunday"
    end
  end

  defp generate_time_options do
    # Generate times from 00:00 to 23:45 in 15-minute intervals
    for hour <- 1..23, minute <- [0, 15, 30, 45] do
      time = Time.new!(hour, minute, 0)
      formatted = format_time(time)
      {formatted, formatted}
    end
  end

  defp format_time(time) do
    time
    |> Time.to_string()
    |> String.slice(0..4) # Converts "09:00:00" to "09:00"
  end

end
