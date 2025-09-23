defmodule SyncMe.Google.Meet do
  @moduledoc """
  Handles integration with Google Meet API via Google Calendar
  to create video conferences.
  """

  alias SyncMe.Bookings.Booking

  @doc """
  Creates a Google Calendar event with a Meet link for a booking.

  This function assumes you have a way to get a valid Google API token
  for the partner whose calendar the event will be created on.

  Returns the `hangoutLink` from the created event.
  """
  def create_event(%Booking{
        event_type: event_type,
        guest_user: guest_user,
        partner: partner,
        start_time: start_time,
        end_time: end_time
      }) do
    with {:ok, token} <- SyncMe.GoogleCalendar.get_valid_access_token(partner) do
      event = %{
        "summary" => event_type.name,
        "guestsCanInviteOthers" => false,
        "description" => event_type.description,
        "start" => %{"dateTime" => DateTime.to_iso8601(start_time)},
        "end" => %{"dateTime" => DateTime.to_iso8601(end_time)},
        "attendees" => [
          %{"email" => guest_user.email},
          %{"email" => partner.user.email, "organizer" => true, "self" => true}
        ],
        "conferenceData" => %{
          "createRequest" => %{
            "requestId" => UUID.uuid4(),
            "conferenceSolutionKey" => %{
              "type" => "hangoutsMeet"
            }
          }
        }
      }

      # or use a specific calendar ID
      calendar_id = "primary"

      case Req.post(
             "https://www.googleapis.com/calendar/v3/calendars/#{calendar_id}/events?conferenceDataVersion=1",
             headers: [
               {"Authorization", "Bearer #{token}"},
               {"Content-Type", "application/json"}
             ],
             json: event
           ) do
        {:ok, response} ->
          IO.inspect("#{inspect(response)}")
          {:ok, Map.get(response.body, "hangoutLink", "Meeting link not available") }

        {:error, reason} ->
          IO.inspect("#{inspect(reason)}")
          {:error, reason }
      end
    end
  end
end
