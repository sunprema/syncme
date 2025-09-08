defmodule SyncMeWeb.BookingEventController do
  use SyncMeWeb, :controller

  def new_session(
        conn,
        %{"event_type_id" => event_type_id, "encodedTimeSelected" => encodedTimeSelected}
      ) do


    conn
    |> put_session(:user_return_to, ~p"/book_event/return/login/#{event_type_id}/#{encodedTimeSelected}")
    |> redirect(to: ~p"/users/log-in")

  end

  def return_session(conn, %{"event_type_id" => event_type_id, "encodedTimeSelected" => encodedTimeSelected}) do
    IO.inspect("Inside return session #{event_type_id}", label: "RETURN SESSION")

    conn
    |> put_session(:user_return_to, nil)
    |> redirect(to: ~p"/book_event/auth/details/#{event_type_id}/#{encodedTimeSelected}")
  end
end
