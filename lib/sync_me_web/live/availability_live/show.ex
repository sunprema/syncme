defmodule SyncMeWeb.AvailabilityLive do
  use SyncMeWeb, :live_view
  alias SyncMe.Partners

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    partner = Partners.get_partner(scope)
    if is_nil(partner) do
      {:ok,
        socket
          |> put_flash(:error, "No partnerships available")
          |> redirect(~p"/partner/signup")

      }
    else
      {:ok,
      socket
      |> assign(partner: partner)
      }
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.partner_layout flash={@flash} current_scope={@current_scope} tab="availability">
    <.header>
    Availability
    <:subtitle>Manage your availability</:subtitle>
    </.header>

    </Layouts.partner_layout>
    """
  end

  @impl true
  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end
end
