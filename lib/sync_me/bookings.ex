defmodule SyncMe.Bookings do
  @moduledoc """
  The Bookings context.
  """

  import Ecto.Query, warn: false
  # alias SyncMe.Billing.Transaction
  alias SyncMe.Partners.Partner
  alias SyncMe.Repo

  alias SyncMe.Bookings.Booking
  alias SyncMe.Accounts.Scope

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
    with {:ok, event_type} <- validate_event_type(attrs),
         {:ok, start_time} <- validate_start_time(attrs),
         :ok <- check_availability(event_type, start_time) do
      # If all validations pass, proceed with the database transaction.
      do_create_booking(guest_user, event_type, start_time)
    else
      # This `else` block catches any error tuple from the `with` chain.
      {:error, reason} -> {:error, reason}
    end
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
    Repo.transaction(fn ->
      # Prepare all the data for the new booking
      booking_attrs = %{
        guest_user_id: guest_user.id,
        partner_id: event_type.partner_id,
        event_type_id: event_type.id,
        start_time: start_time,
        end_time: DateTime.add(start_time, event_type.duration_in_minutes, :minute),
        status: :confirmed,
        # Denormalize for historical accuracy
        price_at_booking: event_type.price,
        duration_at_booking: event_type.duration_in_minutes
      }

      # Insert the booking
      with {:ok, booking} <-
             %Booking{}
             |> Booking.changeset(booking_attrs)
             |> Repo.insert() do
        # --- Placeholder for future logic ---
        # In a real app, you would now:
        # 1. Call the Billing context to create a pending transaction:
        #    Billing.create_pending_transaction(booking)
        # 2. Call a Notifier to schedule reminder emails:
        #    Notifier.schedule_booking_reminders(booking)
        # 3. Generate and add the video conference link.
        #
        # If any of these fail, the transaction will be rolled back.
        # ------------------------------------

        {:ok, booking}
      end
    end)
  end

  # Validation Step 1: Check the EventType
  defp validate_event_type(%{"event_type_id" => id}) do
    case Repo.get(EventType, id) do
      nil ->
        {:error, :event_type_not_found}

      event_type ->
        if event_type.is_active do
          {:ok, event_type}
        else
          {:error, :event_type_not_active}
        end
    end
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
end
