defmodule SyncMeWeb.SettingsLive do
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

      }
    else
      partner_change_set = Partners.change_partner(scope, partner, %{})
      form = to_form(partner_change_set)
      {:ok,
      socket
      |> assign(partner: partner)
      |> assign(form: form)

    }
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.partner_layout flash={@flash} current_scope={@current_scope} tab="settings">
    <.header>
    Profile
    <:subtitle>Manage settings for your SyncMe.Link profile</:subtitle>
    </.header>
    <.live_component module={SyncMeWeb.SettingsLive.SettingsComponent} id={@current_scope.user.id} current_scope={@current_scope}/>
    </Layouts.partner_layout>
    """
  end

  @impl true
  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end
end
