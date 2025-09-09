defmodule SyncMeWeb.UserHome do
  use SyncMeWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.guest_layout tab="upcoming_meetings" flash={@flash} current_scope={@current_scope}>


    </Layouts.guest_layout>
    """
  end

  def handle_params(unsigned_params, _uri, socket) do
    IO.inspect(unsigned_params)
    {:noreply, socket}
  end
end
