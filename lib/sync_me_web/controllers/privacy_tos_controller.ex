defmodule SyncMeWeb.PrivacyAndTOSController do
  use SyncMeWeb, :controller

  def privacy(conn, _params) do
    render(conn, :privacy)
  end

  def tos(conn, _params) do
    render(conn, :tos)
  end
end
