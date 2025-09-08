defmodule SyncMe.Scheduler do
  require Timex

  alias SyncMe.Repo
  alias SyncMe.{Events, Availability, Bookings, Partners}

  alias SyncMe.{
    Availability.AvailabilityRule,
    Events.EventType,
    Bookings.Booking,
    Partners.Partner
  }

  alias SyncMe.Accounts.Scope

  import Ecto.Query, warn: false

  @spec get_availability_for_partner(any(), %{
          :calendar => atom(),
          :day => any(),
          :month => any(),
          :year => any(),
          optional(any()) => any()
        }) :: any()
  def get_availability_for_partner(partner_id, date) do
    day_of_week = Date.day_of_week(date)

    from(r in AvailabilityRule,
      where: r.partner_id == ^partner_id and r.day_of_week == ^day_of_week,
      select: %{start_time: r.start_time, end_time: r.end_time}
    )
    |> Repo.all()
  end

  # Create a booking
  def create_booking(attrs) do
    %Booking{}
    |> Booking.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, booking} ->
        Phoenix.PubSub.broadcast(SyncMe.PubSub, "bookings", {:new_booking, booking})
        {:ok, booking}

      error ->
        error
    end
  end

  # Fetch bookings for a specific date
  def list_bookings_for_date(partner_id, date) do
    start = Timex.beginning_of_day(date)
    endTime = Timex.end_of_day(date)
    start_of_day = DateTime.from_naive!(start, "Etc/UTC")
    end_of_day = DateTime.from_naive!(endTime, "Etc/UTC")

    from(b in Booking,
      where:
        b.partner_id == ^partner_id and
          b.start_time >= ^start_of_day and
          b.start_time <= ^end_of_day,
      preload: [:event_type]
    )
    |> Repo.all()
  end

  # Generate available time slots for a day based on rules and bookings
  def available_slots(partner_id, date, event_type_id) do
    event_type = Repo.get!(EventType, event_type_id)
    duration = event_type.duration_in_minutes
    rules = get_availability_for_partner(partner_id, date)
    bookings = list_bookings_for_date(partner_id, date)

    rules
    |> Enum.flat_map(fn rule ->
      generate_slots_for_rule(rule, date, duration, bookings)
    end)

    # |> Enum.sort_by(& &1.start_time, DateTime)
  end

  def generate_slots_for_rule(rule, date, duration, bookings) do
    naive_date = NaiveDateTime.to_date(date)

    start_dt = DateTime.new!(naive_date, rule.start_time, "Etc/UTC")
    end_dt = DateTime.new!(naive_date, rule.end_time, "Etc/UTC")
    # 15 minutes, in seconds
    slot_interval = 15 * 60
    # Generate slots in 15-minute increments (adjust as needed)
    Stream.iterate(start_dt, &DateTime.add(&1, slot_interval, :second))
    |> Stream.take_while(&(DateTime.compare(&1, end_dt) in [:lt, :eq]))
    |> Enum.filter(fn slot_start ->
      slot_end = DateTime.add(slot_start, duration * 60, :second)

      DateTime.compare(slot_end, end_dt) != :gt and
        not slot_overlaps_booking?(slot_start, slot_end, bookings)
    end)
  end

  def create_booking(
        %Scope{user: user},
        %EventType{} = eventType,
        meetingStartTime,
        price_at_booking
      )
      when not is_nil(user) do
    IO.inspect(
      """
      Event Type: #{inspect(eventType)}
      Meeting Start Time: #{inspect(meetingStartTime)}
      Price at Booking: #{inspect(price_at_booking)}
      """,
      label: "SCHEDULER.CREATE_BOOKING"
    )
  end

  defp slot_overlaps_booking?(slot_start, slot_end, bookings) do
    Enum.any?(bookings, fn b ->
      DateTime.compare(slot_start, b.end_time) != :gt and
        DateTime.compare(slot_end, b.start_time) != :lt
    end)
  end
end
