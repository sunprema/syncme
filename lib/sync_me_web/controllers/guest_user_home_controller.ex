defmodule SyncMeWeb.GuestUserHomeController do
  use SyncMeWeb, :controller

  alias SyncMe.Partners

  def home(conn, %{"syncme_link" => syncme_link}) do
    IO.inspect(syncme_link)
    partner = Partners.get_partner_by_syncme_link(syncme_link)

    conn =
      conn
      |> assign(:syncme_link, syncme_link)
      |> assign(:partner, partner)

    render(conn, :guest_user_home, layout: false)
  end
end
