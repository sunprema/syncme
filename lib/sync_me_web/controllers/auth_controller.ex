defmodule SyncMeWeb.AuthController do
  use SyncMeWeb, :controller

  alias Ueberauth.Strategy.Helpers
  alias SyncMe.Accounts
  alias SyncMe.Partners
  require Logger

  plug Ueberauth

  def request(conn, params) do
    redirect(conn, to: Helpers.callback_url(conn, params))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.inspect("The info #{inspect(auth)}", label: "FROM GOOGLE AUTH")

    case Accounts.get_user_by_session_token(Map.get(get_session(conn), "user_token")) do
      nil ->
        conn
        |> put_flash(:error, "Failed to connect Google calendar.")
        |> redirect(to: ~p"/")

      {user, _token_inserted_at} ->
        # update user profile
        user_params = %{
          email: auth.info.email,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name
        }

        case Accounts.update_user_data_from_google(user, user_params) do
          {:ok, user} ->
            case Partners.get_partner_by_user(user) do
              nil ->
                conn
                |> put_flash(:error, "Partner is not signed up yet")
                |> redirect(to: "/")

              partner ->
                credentials = auth.credentials

                calendar_attrs = %{
                  google_access_token: credentials.token,
                  google_refresh_token: credentials.refresh_token,
                  google_token_expires_at: DateTime.from_unix!(credentials.expires_at)
                }

                case Partners.update_calendar_tokens(partner, calendar_attrs) do
                  {:ok, _updated_partner} ->
                    conn
                    |> put_flash(:info, "Successfully connected your Google Calendar.")
                    |> redirect(to: "/")

                  {:error, changeset} ->
                    IO.inspect("#{inspect(changeset)}", label: "GOOGLE TOKENS UPDATE FAILED")

                    conn
                    |> put_flash(
                      :error,
                      "Could not integrate with your Google Calendar - update tokens failed"
                    )
                    |> redirect(to: "/")
                end
            end

          {:error, changeset} ->
            IO.inspect("#{inspect(changeset)}", label: "GOOGLE USER DATA UPDATE FAILED")

            conn
            |> put_flash(
              :error,
              "Could not integrate with your Google Calendar - user data update failed"
            )
            |> redirect(to: "/")
        end
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: "/")
  end
end
