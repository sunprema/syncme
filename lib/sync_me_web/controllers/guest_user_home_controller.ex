defmodule SyncMeWeb.GuestUserHomeController do
  use SyncMeWeb, :controller

  alias SyncMe.Partners

  def home(conn, %{"syncme_link" => syncme_link}) do
    IO.inspect(syncme_link)

    case Partners.get_partner_by_syncme_link(syncme_link) do
      nil ->
        render(conn, :unknown_syncme_link, layout: false)

      partner ->
        conn
        |> assign(:syncme_link, syncme_link)
        |> assign(:partner, partner)
        |> render(:guest_user_home, layout: false)
    end
  end
end
