defmodule SyncMeWeb.BookingEventController do
  use SyncMeWeb, :controller

  def new_session2(
        conn,
        %{"event_type_id" => event_type_id, "encodedTimeSelected" => encodedTimeSelected}
      ) do
    conn
    |> put_session(
      :user_return_to,
      ~p"/book_event/return/login/#{event_type_id}/#{encodedTimeSelected}"
    )
    |> redirect(to: ~p"/users/log-in")
  end

  def new_session(
        conn,
        %{"event_type_id" => event_type_id, "encodedTimeSelected" => encodedTimeSelected}
      ) do
    scope = " email profile"

    conn
    |> put_session(
      :user_return_to,
      ~p"/book_event/return/login/#{event_type_id}/#{encodedTimeSelected}"
    )
    |> redirect(to: "/auth/google?scope=#{URI.encode(scope)}&prompt=consent&access_type=offline")
  end

  def return_session(conn, %{
        "event_type_id" => event_type_id,
        "encodedTimeSelected" => encodedTimeSelected
      }) do
    IO.inspect("Inside return session #{event_type_id}", label: "RETURN SESSION")

    conn
    |> put_session(:user_return_to, nil)
    |> redirect(to: ~p"/book_event/auth/details/#{event_type_id}/#{encodedTimeSelected}")
  end

  def validate_profile(conn, request) do
    IO.inspect("Received #{inspect(request)}", label: "Validating Profile")
    json(conn, request)
  end
end
