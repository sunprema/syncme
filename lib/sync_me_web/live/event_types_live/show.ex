defmodule SyncMeWeb.EventTypesLive.Show do
  use SyncMeWeb, :live_view
  alias SyncMe.Events


  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit , %{"id" => id}) do
    scope = socket.assigns.current_scope
    event_type = Events.get_event_type(scope, id)
    if is_nil(event_type) do
      socket |> redirect(~p"/users/log-out")
    else
      socket |> assign(:event_type, event_type)
    end
  end

  defp apply_action(socket, :new , _params) do

    socket
      |> assign(:event_type, %Events.EventType{})
  end


end
