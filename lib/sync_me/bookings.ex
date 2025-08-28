defmodule SyncMe.Bookings do
  @moduledoc """
  The Bookings context.
  """

  import Ecto.Query, warn: false
  alias SyncMe.Partners.Partner
  alias SyncMe.Repo

  alias SyncMe.Bookings.Booking
  alias SyncMe.Accounts.Scope

  def list_bookings(%Scope{user: user}, filters \\ %{}) when not is_nil(user) do
    partner = Repo.get_by(Partner, user_id: user.id)

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

  def get_booking!(%Scope{user: user}, id) when not is_nil(user) do
    # Booking can be obtained by Guest user or Partner
    partner = Repo.get_by(Partner, user_id: user.id)

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

  def create_booking(%Scope{} = scope, attrs) do
    with {:ok, booking = %Booking{}} <-
           %Booking{}
           |> Booking.changeset(attrs, scope)
           |> Repo.insert() do
      {:ok, booking}
    end
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
end
