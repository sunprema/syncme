defmodule SyncMe.BookingsTest do
  use SyncMe.DataCase

  alias SyncMe.Bookings

  describe "bookings" do
    alias SyncMe.Bookings.Booking

    import SyncMe.AccountsFixtures, only: [user_scope_fixture: 0]
    import SyncMe.BookingsFixtures

    @invalid_attrs %{status: nil, start_time: nil, end_time: nil, video_conference_link: nil, price_at_booking: nil, duration_at_booking: nil}

    test "list_bookings/1 returns all scoped bookings" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      booking = booking_fixture(scope)
      other_booking = booking_fixture(other_scope)
      assert Bookings.list_bookings(scope) == [booking]
      assert Bookings.list_bookings(other_scope) == [other_booking]
    end

    test "get_booking!/2 returns the booking with given id" do
      scope = user_scope_fixture()
      booking = booking_fixture(scope)
      other_scope = user_scope_fixture()
      assert Bookings.get_booking!(scope, booking.id) == booking
      assert_raise Ecto.NoResultsError, fn -> Bookings.get_booking!(other_scope, booking.id) end
    end

    test "create_booking/2 with valid data creates a booking" do
      valid_attrs = %{status: "some status", start_time: ~U[2025-08-27 00:20:00Z], end_time: ~U[2025-08-27 00:20:00Z], video_conference_link: "some video_conference_link", price_at_booking: "120.5", duration_at_booking: 42}
      scope = user_scope_fixture()

      assert {:ok, %Booking{} = booking} = Bookings.create_booking(scope, valid_attrs)
      assert booking.status == "some status"
      assert booking.start_time == ~U[2025-08-27 00:20:00Z]
      assert booking.end_time == ~U[2025-08-27 00:20:00Z]
      assert booking.video_conference_link == "some video_conference_link"
      assert booking.price_at_booking == Decimal.new("120.5")
      assert booking.duration_at_booking == 42
      assert booking.user_id == scope.user.id
    end

    test "create_booking/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Bookings.create_booking(scope, @invalid_attrs)
    end

    test "update_booking/3 with valid data updates the booking" do
      scope = user_scope_fixture()
      booking = booking_fixture(scope)
      update_attrs = %{status: "some updated status", start_time: ~U[2025-08-28 00:20:00Z], end_time: ~U[2025-08-28 00:20:00Z], video_conference_link: "some updated video_conference_link", price_at_booking: "456.7", duration_at_booking: 43}

      assert {:ok, %Booking{} = booking} = Bookings.update_booking(scope, booking, update_attrs)
      assert booking.status == "some updated status"
      assert booking.start_time == ~U[2025-08-28 00:20:00Z]
      assert booking.end_time == ~U[2025-08-28 00:20:00Z]
      assert booking.video_conference_link == "some updated video_conference_link"
      assert booking.price_at_booking == Decimal.new("456.7")
      assert booking.duration_at_booking == 43
    end

    test "update_booking/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      booking = booking_fixture(scope)

      assert_raise MatchError, fn ->
        Bookings.update_booking(other_scope, booking, %{})
      end
    end

    test "update_booking/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      booking = booking_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Bookings.update_booking(scope, booking, @invalid_attrs)
      assert booking == Bookings.get_booking!(scope, booking.id)
    end

    test "delete_booking/2 deletes the booking" do
      scope = user_scope_fixture()
      booking = booking_fixture(scope)
      assert {:ok, %Booking{}} = Bookings.delete_booking(scope, booking)
      assert_raise Ecto.NoResultsError, fn -> Bookings.get_booking!(scope, booking.id) end
    end

    test "delete_booking/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      booking = booking_fixture(scope)
      assert_raise MatchError, fn -> Bookings.delete_booking(other_scope, booking) end
    end

    test "change_booking/2 returns a booking changeset" do
      scope = user_scope_fixture()
      booking = booking_fixture(scope)
      assert %Ecto.Changeset{} = Bookings.change_booking(scope, booking)
    end
  end
end
