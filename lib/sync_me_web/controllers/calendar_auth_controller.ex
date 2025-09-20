defmodule SyncMeWeb.CalendarAuthController do
  use SyncMeWeb, :controller

  require Logger


  def connect_calendar(conn, _params) do
    scope = " email profile https://www.googleapis.com/auth/calendar.events"
    redirect(conn, to: "/auth/google?scope=#{URI.encode(scope)}&prompt=consent&access_type=offline")
  end

end
