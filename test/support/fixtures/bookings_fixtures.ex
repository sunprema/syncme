defmodule SyncMe.BookingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SyncMe.Bookings` context.
  """

  @doc """
  Generate a booking.
  """
  def booking_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        duration_at_booking: 42,
        end_time: ~U[2025-08-27 00:20:00Z],
        price_at_booking: "120.5",
        start_time: ~U[2025-08-27 00:20:00Z],
        status: "some status",
        video_conference_link: "some video_conference_link"
      })

    {:ok, booking} = SyncMe.Bookings.create_booking(scope, attrs)
    booking
  end
end
