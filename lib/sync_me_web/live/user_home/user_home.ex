defmodule SyncMeWeb.UserHome do
  use SyncMeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="navbar bg-base-100 shadow-sm">
      <div class="navbar-start">
        <div class="dropdown">
          <div tabindex="0" role="button" class="btn btn-ghost btn-circle">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"> <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h7" /> </svg>
          </div>
          <ul
            tabindex="0"
            class="menu menu-sm dropdown-content bg-base-100 rounded-box z-1 mt-3 w-52 p-2 shadow">
            <li><.link patch={~p"/user/home?task=my_meetings"}>My Meetings</.link></li>
            <li><.link patch={~p"/user/home?task=my_availability"}>Availability</.link></li>
            <li><.link patch={~p"/user/home?task=my_about"}>About</.link></li>
          </ul>
        </div>
      </div>
      <div class="navbar-center">
        <a class="btn btn-ghost text-xl">SyncMe Link</a>
      </div>

    </div>
    {@current_scope.user.email}
    """
  end


  def handle_params(unsigned_params, _uri, socket) do
    IO.inspect(unsigned_params)
    {:noreply, socket}
  end

end
