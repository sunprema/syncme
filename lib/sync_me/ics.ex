defmodule SyncMe.Calendar.ICS do
  alias SyncMe.Bookings.Booking

  @doc """
  Generates an ICS calendar invite string for a booking.
  """
  def generate(%Booking{} = booking) do
    event_type = booking.event_type
    partner = booking.partner
    guest = booking.guest_user

    uid = Ecto.UUID.generate()
    now = DateTime.utc_now() |> DateTime.to_string() |> String.replace(~r/[-:]|\.\d+/, "")

    """
    BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//SyncMe//NONSGML v1.0//EN
    BEGIN:VEVENT
    UID:#{uid}@syncme.local
    DTSTAMP:#{now}
    ORGANIZER;CN=#{partner.user.name}:MAILTO:#{partner.user.email}
    ATTENDEE;CN=#{guest.name};ROLE=REQ-PARTICIPANT:MAILTO:#{guest.email}
    DTSTART:#{format_time(booking.start_time)}
    DTEND:#{format_time(booking.end_time)}
    SUMMARY:#{event_type.name}
    DESCRIPTION:#{event_type.description || "Booking via SyncMe."}\\nVideo Conference: #{booking.video_conference_link}
    LOCATION:#{booking.video_conference_link}
    END:VEVENT
    END:VCALENDAR
    """
  end

  defp format_time(datetime),
    do: datetime |> DateTime.to_string() |> String.replace(~r/[-:]|\.\d+/, "")
end
