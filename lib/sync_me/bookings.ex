defmodule SyncMe.Bookings do
  @moduledoc """
  The Bookings context.
  """

  import Ecto.Query, warn: false
  # alias SyncMe.Billing.Transaction
  alias SyncMe.Accounts.Scope
  alias SyncMe.Availability.AvailabilityRule
  alias SyncMe.Bookings.Booking
  alias SyncMe.Events.EventType
  alias SyncMe.Partners.Partner
  alias SyncMe.Repo
  alias SyncMe.Workers.SendBookingEmails

  require Timex
  alias Phoenix.PubSub

  def list_bookings(%Scope{user: user, partner: partner}, filters \\ %{}) when not is_nil(user) do
    base_query =
      cond do
        !is_nil(partner) ->
          from b in Booking,
            where: b.partner_id == ^partner.id,
            preload: [:guest_user, :event_type]

        true ->
          from b in Booking,
            where: b.guest_user_id == ^user.id,
            preload: [partner: [user: :partner], event_type: []]
      end

    query_with_filters = apply_booking_filters(base_query, filters)
    Repo.all(query_with_filters)
  end

  def get_booking!(%Scope{user: user, partner: partner}, id) when not is_nil(user) do
    # Booking can be obtained by Guest user or Partner
    base_query =
      cond do
        !is_nil(partner) ->
          from b in Booking,
            where: b.partner_id == ^partner.id and b.id == ^id,
            preload: [:guest_user, :event_type]

        true ->
          from b in Booking,
            where: b.guest_user_id == ^user.id and b.id == ^id,
            preload: [partner: [user: :partner], event_type: []]
      end

    Repo.one!(base_query)
  end

  @doc """

  Creates a new booking for a given event_type and start_time.
  This is a transactional operation that validates the inputs, checks for
  availability, and creates the booking record.

  ## Attributes:
    - `event_type_id` (required): The ID of the service being booked.
    - `start_time` (required): The proposed start time in ISO8601 UTC format.

  ## Returns:
    - `{:ok, booking}` on success.
    - `{:error, :user_not_authenticated}` if the user is not logged in.
    - `{:error, :event_type_not_found}` if the event_type_id is invalid.
    - `{:error, :event_type_not_active}` if the partner has disabled the event type.

    - `{:error, :invalid_start_time}` if the time is in the past or malformed.
    - `{:error, :slot_not_available}` if the time slot is not within the partner's availability or is already booked.
    - `{:error, changeset}` on a database validation error.

  """
  def create_booking(%Scope{user: guest_user}, attrs) when not is_nil(guest_user) do
    attrs = Map.put(attrs, "guest_user_id", guest_user.id)
    Repo.insert(Booking.changeset(%Booking{}, attrs))
  end

  def create_booking(%Scope{user: nil}, _attrs) do
    {:error, :user_not_authenticated}
  end

  def delete_booking(%Scope{} = scope, %Booking{} = booking) do
    # only the partner or guest can cancel a booking.
    # TODO: Think about only future bookings can be cancelled.
    with :ok <- verify_booking_ownership(scope, booking) do
      Repo.delete(booking)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def cancel_booking_by_user(%Scope{} = scope, %Booking{} = booking) do
    with :ok <- verify_booking_ownership(scope, booking) do
      cs = Booking.changeset(booking, %{"status" => "cancelled_by_guest"})
      Repo.update(cs)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def cancel_booking_by_partner(%Scope{} = scope, %Booking{} = booking) do
    with :ok <- verify_booking_ownership(scope, booking) do
      cs = Booking.changeset(booking, %{"status" => "cancelled_by_partner"})
      Repo.update(cs)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Generates a video conference link for a booking.

  In a real application, this would integrate with a service like
  Google Meet or Zoom to generate a unique link. For now, it returns a
  static placeholder link.
  """
  def generate_video_conference_link(_booking_or_attrs \\ %{}) do
    # TODO: Integrate with a real video conferencing service API
    "https://meet.google.com/mnd-tpqm-gbb"
  end

  # --- Private Helper for Filtering ---

  defp apply_booking_filters(query, %{"status" => status}) when not is_nil(status) do
    # Example: filter by a specific status
    from q in query, where: q.status == ^String.to_existing_atom(status)
  end

  defp apply_booking_filters(query, %{"upcoming" => true}) do
    # Example: filter for only upcoming bookings
    from q in query, where: q.start_time > ^DateTime.utc_now()
  end

  # If no recognized filters are passed, return the original query.
  defp apply_booking_filters(query, _filters) do
    query
  end

  defp verify_booking_ownership(%Scope{user: user}, %Booking{} = booking) when not is_nil(user) do
    partner = Repo.get_by(Partner, user_id: user.id)

    cond do
      partner && partner.id == booking.partner_id ->
        :ok

      user.id == booking.guest_user_id ->
        :ok

      true ->
        {:error, :not_found_or_unauthorized}
    end
  end

  defp verify_booking_ownership(%Scope{user: nil}, _rule) do
    {:error, :user_not_authenticated}
  end

  defp do_create_booking(guest_user, event_type, start_time) do
    Repo.transact(fn ->
      booking_attrs = %{
        guest_user_id: guest_user.id,
        partner_id: event_type.partner_id,
        event_type_id: event_type.id,
        start_time: start_time,
        end_time: DateTime.add(start_time, event_type.duration_in_minutes, :minute),
        video_conference_link: generate_video_conference_link(),
        status: :confirmed,
        # Denormalize for historical accuracy
        price_at_booking: event_type.price,
        duration_at_booking: event_type.duration_in_minutes
      }

      with {:ok, booking} <-
             %Booking{}
             |> Booking.changeset(booking_attrs)
             |> Repo.insert() do
        # --- Placeholder for future logic ---
        # In a real app, you would now:
        # 1. Call Billing context for transactions.
        booking = Repo.preload(booking, [:event_type])
        SendBookingEmails.new(%{booking_id: booking.id}, max_attempts: 2) |> Oban.insert()
        PubSub.broadcast(SyncMe.PubSub, "bookings", {:new_booking, booking})
        {:ok, booking}
      end
    end)
  end

  defp validate_event_type(_attrs), do: {:error, :event_type_not_found}

  # Validation Step 2: Check the Start Time
  defp validate_start_time(%{"start_time" => time_str}) do
    case DateTime.from_iso8601(time_str) do
      {:ok, start_time, _offset} ->
        if DateTime.compare(start_time, DateTime.utc_now()) == :gt do
          {:ok, start_time}
        else
          # It's in the past
          {:error, :invalid_start_time}
        end

      {:error, _} ->
        # It's malformed
        {:error, :invalid_start_time}
    end
  end

  defp validate_start_time(_attrs), do: {:error, :invalid_start_time}

  # Validation Step 3: Check Availability (The Core Business Logic)
  defp check_availability(event_type, start_time) do
    # This is a simplified check. A full implementation would be more complex
    # and would live in your Availability context.

    end_time = DateTime.add(start_time, event_type.duration_in_minutes, :minute)

    # Check for overlapping bookings for this partner
    overlapping_booking_exists? =
      from(b in Booking,
        where:
          b.partner_id == ^event_type.partner_id and
            b.status == :confirmed and
            (b.start_time < ^end_time and b.end_time > ^start_time)
      )
      |> Repo.exists?()

    # In a full app, you would also check against the Partner's Availability rules here.
    # For example:
    # is_within_partner_schedule? = Availability.is_slot_within_rules?(event_type.partner, start_time, end_time)

    # or !is_within_partner_schedule?
    if overlapping_booking_exists? do
      {:error, :slot_not_available}
    else
      :ok
    end
  end

  # --- Scheduling and Availability Helpers ---

  @doc """
  Generates available time slots for a given partner, date, and event type.
  """
  def available_slots(partner_id, date, event_type_id) do
    event_type = Repo.get!(EventType, event_type_id)
    duration = event_type.duration_in_minutes
    rules = get_availability_for_partner(partner_id, date)
    bookings = list_bookings_for_date(partner_id, date)

    rules
    |> Enum.flat_map(fn rule ->
      generate_slots_for_rule(rule, date, duration, bookings)
    end)
  end

  @doc """
  Fetches all availability rules for a partner for a given date.
  """
  def get_availability_for_partner(partner_id, date) do
    day_of_week = Date.day_of_week(date)

    from(r in AvailabilityRule,
      where: r.partner_id == ^partner_id and r.day_of_week == ^day_of_week,
      select: %{start_time: r.start_time, end_time: r.end_time}
    )
    |> Repo.all()
  end

  @doc """
  Fetches all bookings for a partner on a specific date.
  """
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

  defp generate_slots_for_rule(rule, date, duration, bookings) do
    naive_date = NaiveDateTime.to_date(date)

    start_dt = DateTime.new!(naive_date, rule.start_time, "Etc/UTC")
    end_dt = DateTime.new!(naive_date, rule.end_time, "Etc/UTC")
    slot_interval = 15 * 60

    Stream.iterate(start_dt, &DateTime.add(&1, slot_interval, :second))
    |> Stream.take_while(&(DateTime.compare(&1, end_dt) in [:lt, :eq]))
    |> Enum.filter(fn slot_start ->
      slot_end = DateTime.add(slot_start, duration * 60, :second)

      DateTime.compare(slot_end, end_dt) != :gt and
        not slot_overlaps_booking?(slot_start, slot_end, bookings)
    end)
  end

  defp slot_overlaps_booking?(slot_start, slot_end, bookings) do
    Enum.any?(bookings, fn b ->
      DateTime.compare(slot_start, b.end_time) != :gt and
        DateTime.compare(slot_end, b.start_time) != :lt
    end)
  end
end
