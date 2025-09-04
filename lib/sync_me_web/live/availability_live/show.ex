defmodule SyncMeWeb.AvailabilityLive.Show do
  use SyncMeWeb, :live_view
  alias SyncMe.Availability
  alias SyncMe.Availability.AvailabilityRule
  alias SyncMe.Partners


  @impl true
  def mount(_params, _session, socket) do
    availability_rules = Availability.list_availability_rules(socket.assigns.current_scope)
    IO.inspect(availability_rules, label: "Availability Rules")
    days = [

      %{day_of_week: 1, enabled: false, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 2, enabled: false, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 3, enabled: false, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 4, enabled: false, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 5, enabled: false, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 6, enabled: false, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
      %{day_of_week: 7, enabled: false, start_time: ~T[09:00:00], end_time: ~T[17:00:00]},
    ]

    updated_days = case availability_rules do
      nil ->
        days
      rules ->
          Enum.map(days, fn day ->
        case Enum.find(rules, fn rule -> rule.day_of_week == day.day_of_week end) do
          nil -> day
          rule ->
            %{day |
              enabled: true,
              start_time: rule.start_time,
              end_time: rule.end_time
            }
        end
      end)
    end


    IO.inspect(updated_days, label: "MERGED DAYS")



    socket =
      socket
      |> assign(:days, updated_days)
      |> assign(:time_options, generate_time_options())

    {:ok, socket}

  end


  @impl true
  def handle_event("toggle_day", %{"day_str" => day_str}, socket) do
    day_index = String.to_integer(day_str) - 1

    days =
      socket.assigns.days
      |> List.update_at(day_index, fn day ->
        %{day | enabled: !day.enabled}
      end)

    {:noreply, assign(socket, :days, days)}
  end

  @impl true
  def handle_event("update_start_time", %{"day" => day,  "start_time" => value}, socket) do
    IO.inspect(value, label: "Start time value")
    day_index = day - 1
    days =
      socket.assigns.days
      |> List.update_at(day_index, fn day ->
          %{day | start_time: parse_time(value) }
      end)
    IO.inspect( days, label: "Inside update_start_time")
    {:noreply, assign(socket, :days, days)}
  end


  @impl true
  def handle_event("update_end_time", %{"day" => day,  "end_time" => value}, socket) do
    IO.inspect(value, label: "End time value")
    day_index = day - 1
    days =
      socket.assigns.days
      |> List.update_at(day_index, fn day ->
          %{day | end_time: parse_time(value) }
      end)
    IO.inspect( days, label: "Inside update_end_time")
    {:noreply, assign(socket, :days, days)}
  end



  @impl true
  def handle_event("save", _params, socket) do
    enabled_rules = Enum.filter(socket.assigns.days, & &1.enabled)
    socket = case Availability.save_availability_rule(socket.assigns.current_scope, enabled_rules) do
      {:ok, _results} ->
        socket
        |> put_flash(:info, "Saved your availability")
        |> redirect(to: socket.assigns.uri.path)
      {:error, _} ->
        socket
        |> put_flash(:error, "Couldnt save your availability. Check If the start time and end time are corect.")
    end
    {:noreply, socket}
  end

  @impl true
  @spec handle_params(any(), any(), any()) :: {:noreply, any()}
  def handle_params(_unsigned_params, uri, socket) do
    {:noreply, assign(socket, uri: URI.parse(uri))}
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
