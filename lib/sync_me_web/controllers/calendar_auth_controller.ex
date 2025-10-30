defmodule SyncMeWeb.CalendarAuthController do
  use SyncMeWeb, :controller

  require Logger
  @scope " email profile https://www.googleapis.com/auth/calendar.events"

  def connect_calendar(conn, _params) do
    redirect(conn,
      to: "/auth/google?scope=#{URI.encode(@scope)}&prompt=consent&access_type=offline"
    )
  end
end
