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
      |> Repo.preload([:event_type, :partner, guest_user: :user, partner: :user])

    ics_content = ICS.generate(booking)
    guest = booking.guest_user
    partner = booking.partner

    # Email to Guest
    BookingMailer.booking_confirmation_email(booking, guest.email, guest.name, ics_content)
    |> Mailer.deliver_later()

    # Email to Partner
    BookingMailer.booking_confirmation_email(
      booking,
      partner.user.email,
      partner.user.name,
      ics_content
    )
    |> Mailer.deliver_later()

    :ok
  end
end
