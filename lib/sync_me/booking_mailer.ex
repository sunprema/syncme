defmodule SyncMe.BookingMailer do
  use Swoosh.Mailer, otp_app: :sync_me

  alias SyncMe.Bookings.Booking
  import Swoosh.Email

  def booking_confirmation_email(
        %Booking{} = booking,
        recipient_email,
        recipient_name,
        ics_content
      ) do
    event_type = booking.event_type
    from_address = {"SyncMe", "no-reply@syncme.local"}

    new()
    |> to({recipient_name, recipient_email})
    |> from(from_address)
    |> subject("Confirmed: #{event_type.name} on #{format_date(booking.start_time)}")
    |> text_body("""
    Hi #{recipient_name},

    Your booking for "#{event_type.name}" is confirmed.

    When: #{format_date(booking.start_time)}
    Video Conference: #{booking.video_conference_link}

    Please find the calendar invite attached.
    """)
    |> attachment(%Swoosh.Attachment{data: ics_content, filename: "invite.ics", content_type: "text/calendar"})
  end

  defp format_date(datetime),
    do: Timex.format!(datetime, "%Y-%m-%d  at %I:%M %p %Z", :strftime)
end
