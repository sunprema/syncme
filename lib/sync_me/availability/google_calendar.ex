defmodule SyncMe.GoogleCalendar do
  @moduledoc """
  Context for interacting with the Google Calendar API.
  """
  alias SyncMe.Partners.Partner
  alias SyncMe.Partners

  @token_uri "https://oauth2.googleapis.com/token"
  @free_busy_uri "https://www.googleapis.com/calendar/v3/freeBusy"

  @doc """
  Fetches busy time intervals for a partner from their primary Google Calendar.
  """
  def get_busy_times(%Partner{} = partner, time_min, time_max) do
    with {:ok, access_token} <- get_valid_access_token(partner) do
      body = %{
        timeMin: DateTime.to_iso8601(time_min),
        timeMax: DateTime.to_iso8601(time_max),
        items: [%{id: "primary"}]
      }

      case Req.post(@free_busy_uri,
             auth: {:bearer, access_token},
             json: body,
             headers: %{"content-type" => "application/json"}
           ) do
        {:ok, %{status: 200, body: %{"calendars" => %{"primary" => %{"busy" => busy_times}}}}} ->
          busy_intervals =
            Enum.map(busy_times, fn %{"start" => start_str, "end" => end_str} ->
              {:ok, start_dt, _} = DateTime.from_iso8601(start_str)
              {:ok, end_dt, _} = DateTime.from_iso8601(end_str)
              {start_dt, end_dt}
            end)

          {:ok, busy_intervals}

        {:ok, resp} ->
          {:error, {:google_api_error, resp.body}}

        {:error, reason} ->
          {:error, {:http_error, reason}}
      end
    end
  end

  def get_valid_access_token(%Partner{google_refresh_token: nil}),
    do: {:error, :no_refresh_token}

  def get_valid_access_token(%Partner{} = partner) do
    # Check if token is expired or close to expiring (e.g., within 5 minutes)
    if DateTime.compare(
         partner.google_token_expires_at,
         DateTime.add(DateTime.utc_now(), 300, :second)
       ) == :lt do
      refresh_access_token(partner)
    else
      {:ok, partner.google_access_token}
    end
  end

  defp refresh_access_token(%Partner{} = partner) do
    client_id = Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)[:client_id]

    client_secret =
      Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)[:client_secret]

    params = [
      client_id: client_id,
      client_secret: client_secret,
      refresh_token: partner.google_refresh_token,
      grant_type: "refresh_token"
    ]

    case Req.post(@token_uri, form: params) do
      {:ok, %{status: 200, body: %{"access_token" => new_token, "expires_in" => expires_in}}} ->
        expires_at = DateTime.add(DateTime.utc_now(), expires_in, :second)

        update_attrs = %{
          google_access_token: new_token,
          google_token_expires_at: expires_at
        }

        with {:ok, _updated_partner} <- Partners.update_calendar_tokens(partner, update_attrs) do
          {:ok, new_token}
        end

      {:ok, resp} ->
        {:error, {:token_refresh_failed, resp.body}}

      {:error, reason} ->
        {:error, {:http_error, reason}}
    end
  end
end
