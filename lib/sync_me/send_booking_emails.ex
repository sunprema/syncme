defmodule SyncMe.Workers.SendBookingEmails do
  use Oban.Worker, queue: :default

  alias SyncMe.Repo
  alias SyncMe.Bookings.Booking
  alias SyncMe.Calendar.ICS
  alias SyncMe.BookingMailer


  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"booking_id" => booking_id}}) do
    booking =
      Repo.get!(Booking, booking_id)
      |> Repo.preload([:event_type,  :guest_user, partner: :user,])

    ics_content = ICS.generate(booking)
    guest = booking.guest_user
    partner = booking.partner

    # Email to Guest
    BookingMailer.booking_confirmation_email(booking, guest.email, guest.first_name, ics_content)
    |> BookingMailer.deliver()

    # Email to Partner
    BookingMailer.booking_confirmation_email(
      booking,
      partner.user.email,
      partner.user.first_name,
      ics_content
    )
    |> BookingMailer.deliver()

    :ok
  end
end
