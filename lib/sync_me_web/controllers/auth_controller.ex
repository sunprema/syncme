defmodule SyncMeWeb.AuthController do
  use SyncMeWeb, :controller

  alias Ueberauth.Strategy.Helpers
  alias SyncMe.Accounts
  alias SyncMeWeb.UserAuth
  alias SyncMe.Partners
  require Logger

  plug Ueberauth

  def request(conn, _params) do
    Phoenix.Controller.redirect(conn, to: Helpers.callback_url(conn))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    email = auth.info.email

    case Accounts.get_user_by_email(email) do
      nil ->
        # User does not exist, so create a new user
        user_params = %{
          email: email,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name
        }

        case Accounts.register_oauth_user(user_params) do
          {:ok, user} ->
            UserAuth.log_in_user(conn, user)

          {:error, changeset} ->
            Logger.error("Failed to create user #{inspect(changeset)}.")

            conn
            |> put_flash(:error, "Failed to create user.")
            |> redirect(to: ~p"/")
        end

      user ->
        # User exists, update session or other details if necessary
        #check If user is a partner as well.
        case Partners.get_partner_by_user( user ) do
          nil ->
            UserAuth.log_in_user(conn, user)
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
                  |> redirect(to: ~p"/partner/home") # Redirect to a relevant page

                {:error, _changeset} ->
                  conn
                  |> put_flash(:error, "Could not integrate with your Google Calendar")
                  |> redirect(to: ~p"/partner/availability")
              end


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
