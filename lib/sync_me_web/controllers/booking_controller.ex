defmodule SyncMeWeb.BookingEventController do
  use SyncMeWeb, :controller

  def new_session(conn, %{"event_type_id" => event_type_id} ) do

    booking_details = %{ event_type_id: event_type_id }

    conn
    |> put_session( :booking_details, booking_details)
    |> put_session(:user_return_to, ~p"/book_event/return/login/#{event_type_id}")
    |> redirect(to: ~p"/users/register")

  end


  def return_session(conn, %{"event_type_id" => event_type_id}) do
      IO.inspect("Inside return session #{event_type_id}", label: "RETURN SESSION")
      conn
      |> put_session(:user_return_to, nil)
      |> redirect(to: ~p"/book_event/auth/details/#{event_type_id}")
  end

end
