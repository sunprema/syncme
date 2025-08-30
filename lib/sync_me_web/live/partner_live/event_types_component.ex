defmodule SyncMeWeb.PartnerLive.EventTypesComponent do

alias SyncMe.Events.EventType
  use SyncMeWeb, :live_component
  alias SyncMe.Partners
  alias SyncMe.Events


  @impl true
  def render(assigns) do
    ~H"""
    <div>
    <Layouts.app flash={@flash} current_scope={@current_scope}>
    <div class="mx-auto max-w-md">
        <div class="text-start">
          <.header>
            Event Types
            <:subtitle>Create events for people to book on your calendar</:subtitle>
          </.header>
        </div>

        <.form for={@form} id="event_type_form" phx-debounce="2000"  phx-submit="create" phx-change="validate" phx-target={@myself}>
          <.input
            field={@form[:name]}
            label="Title"
            placeholder="Intro"
            required
            phx-mounted={JS.focus()}

          />
          <.input
            field={@form[:slug]}
            label="URL"
            placeholder="https://syncme.link/<>/intro"
            required
          />
          <.input
            field={@form[:description]}
            label="Description"
            type="textarea"
            rows="12"
            required
            phx-debounce="2000"

          />

          <.input
            field={@form[:duration_in_minutes]}
            label="Duration"
            type="number"
            placeholder="minutes"
            required
          />

          <.input
            field={@form[:price]}
            label="Minimum fee"
            type="currency"
            placeholder=" in USD"
            required
          />

          <.input
            type="checkbox"
            field={@form[:is_active]}
            label="Active"
            required
          />
          <button phx-disable-with="Creating event type..." class="btn btn-neutral w-full font-normal">
            Create
          </button>
        </.form>

        <footer class="footer absolute left-50 right-50 mx-auto bottom-4 text-center footer-center  text-base-content p-4">
          <aside>
            <p class="text-xs text-center">
              By continuing, you agree to SyncMe.Link's
              <a><span class="font-semibold">Terms of Service</span></a>
              and <a><span class="font-semibold">Privacy Policy</span></a>
            </p>
          </aside>
        </footer>
      </div>
    </Layouts.app>
    </div>
    """
  end

  @impl true
  def mount(socket) do
   {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    scope = assigns.current_scope
    partner = Partners.get_partner(scope)
    if is_nil(partner) do
      {:ok,
        socket
          |> assign(:current_scope, scope)
          |> put_flash(:error, "No partnerships available")

      }
    else
      change_set = Events.change_event_type(scope, %Events.EventType{})
      form = to_form(change_set)
      {:ok,
      socket
      |> assign(:current_scope, scope)
      |> assign(partner: partner)
      |> assign(form: form)

    }
    end
  end

  @impl true
  def handle_event("validate", %{"event_type" => event_type} = _params, socket) do
    scope = socket.assigns.current_scope
    change_set = Events.change_event_type(scope, %EventType{}, event_type)
    change_set = Map.put(change_set, :action, :validate)
    {:noreply ,
    assign(socket, form: to_form(change_set))
  }

  end

  @impl true
  def handle_event("create", %{"event_type" => event_type} = _params, socket) do
    scope = socket.assigns.current_scope

   case Events.create_event_type(scope, event_type) do
    {:ok, _event_type} ->
      {:noreply,
      socket
      |> put_flash(:info, "Event Type created.")


      }
    {:error, changeset} ->
      IO.inspect(changeset)
      changeset = Map.put(changeset, :action, :validate)
      {:noreply ,
        socket
        |> put_flash(:error, "Couldnt change event type.")
        |> assign( form: to_form(changeset))
    }
   end

  end

end
