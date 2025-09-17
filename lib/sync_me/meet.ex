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
  def create_event3(%Booking{
        event_type: event_type,
        guest_user: guest_user,
        partner: partner,
        start_time: start_time,
        end_time: end_time
      }) do
    with {:ok, token} <- SyncMe.GoogleCalendar.get_valid_access_token(partner) do
      client = GoogleApi.Calendar.V3.Connection.new(token)
      # We'll create the event on the partner's primary calendar.
      calendar_id = "primary"

      event_payload = %GoogleApi.Calendar.V3.Model.Event{
        summary: event_type.name,
        description: event_type.description,
        start: %GoogleApi.Calendar.V3.Model.EventDateTime{
          dateTime: DateTime.to_iso8601(start_time),
          timeZone: "Etc/UTC"
        },
        end: %GoogleApi.Calendar.V3.Model.EventDateTime{
          dateTime: DateTime.to_iso8601(end_time),
          timeZone: "Etc/UTC"
        },
        attendees: [
          %GoogleApi.Calendar.V3.Model.EventAttendee{email: guest_user.email},
          %GoogleApi.Calendar.V3.Model.EventAttendee{email: partner.user.email}
        ],
        # This section tells Google to create a Meet link.
        conferenceData: %GoogleApi.Calendar.V3.Model.ConferenceData{
          createRequest: %GoogleApi.Calendar.V3.Model.CreateConferenceRequest{
            requestId: UUID.uuid4(),
            conferenceSolutionKey: %GoogleApi.Calendar.V3.Model.ConferenceSolutionKey{
              type: "hangoutsMeet"
            }
          }
        }
      }

      # API options to enable conference data and notify attendees.
      opts = [
        conferenceDataVersion: 1,
        sendNotifications: true
      ]

      case GoogleApi.Calendar.V3.Api.Events.calendar_events_insert(
             client,
             calendar_id,
             event_payload
           ) do
        {:ok, event} ->
          {:ok, event.hangoutLink}

        {:error, reason} ->
          {:error, {:google_api_error, reason}}
      end
    end
  end

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
          %{"email" => partner.user.email, "organizer" => true, "self" => true},
        ],
        "conferenceData" => %{"createRequest" => %{
            "requestId" => UUID.uuid4(),
            "conferenceSolutionKey" => %{
              "type" => "hangoutsMeet"
            }
          }
        }
      }

      # or use a specific calendar ID
      calendar_id = "primary"


      case Req.post("https://www.googleapis.com/calendar/v3/calendars/#{calendar_id}/events?conferenceDataVersion=1",
        headers: [
          {"Authorization", "Bearer #{token}"},
          {"Content-Type", "application/json"}
        ],
        json: event
      ) do
        {:ok, response} ->
          IO.inspect("#{inspect(response)}")
          response
        {:error, reason} ->
            IO.inspect("#{inspect(reason)}")
            reason
      end


    end
  end
end
