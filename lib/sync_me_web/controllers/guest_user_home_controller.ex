defmodule SyncMeWeb.GuestUserHomeController do
  use SyncMeWeb, :controller

  def home(conn, %{"syncme_link" => syncme_link}) do
    IO.inspect(syncme_link)

    conn =
      conn
      |> assign(:syncme_link, syncme_link)

    render(conn, :guest_user_home, layout: false)
  end
end
