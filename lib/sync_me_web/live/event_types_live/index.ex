defmodule SyncMeWeb.EventTypesLive.Index do
  use SyncMeWeb, :live_view
  alias SyncMe.Events

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    {:ok,
    stream(socket, :event_types, Events.list_event_types(scope))}
  end

end
