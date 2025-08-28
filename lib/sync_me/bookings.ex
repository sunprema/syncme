defmodule SyncMe.Bookings do
  @moduledoc """
  The Bookings context.
  """

  import Ecto.Query, warn: false
  alias SyncMe.Partners.Partner
  alias SyncMe.Repo

  alias SyncMe.Bookings.Booking
  alias SyncMe.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any booking changes.

  The broadcasted messages match the pattern:

    * {:created, %Booking{}}
    * {:updated, %Booking{}}
    * {:deleted, %Booking{}}

  """
  def subscribe_bookings(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SyncMe.PubSub, "user:#{key}:bookings")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(SyncMe.PubSub, "user:#{key}:bookings", message)
  end

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

  @doc """
  Gets a single booking.

  Raises `Ecto.NoResultsError` if the Booking does not exist.

  ## Examples

      iex> get_booking!(scope, 123)
      %Booking{}

      iex> get_booking!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_booking!(%Scope{} = scope, id) do
    Repo.get_by!(Booking, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a booking.

  ## Examples

      iex> create_booking(scope, %{field: value})
      {:ok, %Booking{}}

      iex> create_booking(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_booking(%Scope{} = scope, attrs) do
    with {:ok, booking = %Booking{}} <-
           %Booking{}
           |> Booking.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, booking})
      {:ok, booking}
    end
  end

  """
  def update_booking(%Scope{} = scope, %Booking{} = booking, attrs) do
    true = booking.user_id == scope.user.id

    with {:ok, booking = %Booking{}} <-
           booking
           |> Booking.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, booking})
      {:ok, booking}
    end
  end

  @doc \"""
  Deletes a booking.

  ## Examples

      iex> delete_booking(scope, booking)
      {:ok, %Booking{}}

      iex> delete_booking(scope, booking)
      {:error, %Ecto.Changeset{}}

  """

  def delete_booking(%Scope{} = scope, %Booking{} = booking) do
    true = booking.user_id == scope.user.id

    with {:ok, booking = %Booking{}} <-
           Repo.delete(booking) do
      broadcast(scope, {:deleted, booking})
      {:ok, booking}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking booking changes.

  ## Examples

      iex> change_booking(scope, booking)
      %Ecto.Changeset{data: %Booking{}}

  """
  def change_booking(%Scope{} = scope, %Booking{} = booking, attrs \\ %{}) do
    true = booking.user_id == scope.user.id

    Booking.changeset(booking, attrs, scope)
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
end
