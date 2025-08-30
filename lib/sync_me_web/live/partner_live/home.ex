defmodule SyncMeWeb.PartnerLive.Home do
  use SyncMeWeb, :live_view

  import SyncMeWeb.PartnerLive.Component

  def render(assigns) do
    ~H"""

    <div class="drawer md:drawer-open">
    <input id="my-drawer" type="checkbox" class="drawer-toggle " />
    <div class="drawer-content px-4 ">
    <label for="my-drawer" class="btn btn-primary drawer-button md:hidden">Open drawer</label>

    <.partner_bookings :if={@tab == "bookings"}/>
    <.live_component :if={@tab == "event_types"} module={SyncMeWeb.PartnerLive.EventTypesComponent} id={@current_scope.user.id} current_scope={@current_scope}/>

    <.partner_availability :if={@tab == "availability"}/>
    <.partner_insights :if={@tab == "insights"}/>
    <.live_component :if={@tab == "settings"} module={SyncMeWeb.PartnerLive.SettingsComponent} id={@current_scope.user.id} current_scope={@current_scope}/>

    </div>
    <div class="drawer-side z-10">
      <label for="my-drawer" aria-label="close sidebar" class="drawer-overlay"></label>
      <ul class="menu bg-base-200 text-base-content min-h-full w-80 p-4">
      <!-- Sidebar content here -->
        <li><.link patch={~p"/partner/home/event_types"} class={[@tab == "event_types" && "menu-active"]} >
             <.icon name="hero-link-mini" class="size-4 shrink-0" /> Event Types
        </.link>
        </li>
        <li><.link patch={~p"/partner/home/bookings"}  class={[@tab == "bookings" && "menu-active"]} >
         <.icon name="hero-calendar-mini" class="size-4 shrink-0" />
        Bookings</.link></li>
        <li><.link patch={~p"/partner/home/availability"} class={[@tab == "availability" && "menu-active"]} >
        <.icon name="hero-clock" class="size-4 shrink-0" />Availability</.link></li>
        <li><.link patch={~p"/partner/home/insights"}  class={[@tab == "insights" && "menu-active"]} >
        <.icon name="hero-chart-bar-square" class="size-4 shrink-0" />
        Insights</.link></li>
        <li><.link patch={~p"/partner/home/settings"}  class={[@tab == "settings" && "menu-active"]} >
        <.icon name="hero-cog-6-tooth" class="size-4 shrink-0" />Settings</.link></li>
      </ul>
    </div>
    </div>
    """
  end


  @spec handle_params(map(), any(), any()) :: {:noreply, any()}
  def handle_params(%{"tab" => tab}, _uri, socket) do

    IO.inspect(tab)
    {:noreply,
      socket
      |> assign(tab: tab)
    }
  end

  @spec handle_params(map(), any(), any()) :: {:noreply, any()}
  def handle_params(_params, _uri, socket) do
    {:noreply,
      socket
      |> assign(tab: "event_types")
    }
  end


end
