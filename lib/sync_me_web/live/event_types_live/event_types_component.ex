defmodule SyncMeWeb.PartnerLive.EventTypesComponent do
  alias SyncMe.Events.EventType
  use SyncMeWeb, :live_component
  alias SyncMe.Partners
  alias SyncMe.Events
  alias SyncMe.Blockchain.Contracts.SyncMeEscrow

  @impl true
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="mx-auto w-full" id="create_event_container" phx-hook="EventTypeHook">
      <.form
        for={@form}
        id="event_type_form"
        phx-debounce="2000"
        phx-submit="create"
        phx-change="validate"
        phx-target={@myself}
      >
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
          type="number"
          placeholder=" in USD"
          required
        />

        <.input
          type="checkbox"
          field={@form[:is_active]}
          label="Active"
          required
        />
        <button phx-disable-with="Saving Event Type..." class="btn btn-neutral w-full font-normal">
          Save Event Type
        </button>
      </.form>
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
       |> put_flash(:error, "No partnerships available")}
    else
      change_set = Events.change_event_type(scope, assigns.event_type)
      form = to_form(change_set)

      {:ok,
       socket
       |> assign(:current_scope, scope)
       |> assign(partner: partner)
       |> assign(form: form)}
    end
  end

  @impl true
  def handle_event("validate", %{"event_type" => event_type} = _params, socket) do
    scope = socket.assigns.current_scope
    change_set = Events.change_event_type(scope, %EventType{}, event_type)
    change_set = Map.put(change_set, :action, :validate)
    {:noreply, assign(socket, form: to_form(change_set))}
  end

  @impl true
  def handle_event("create", %{"event_type" => event_type} = _params, socket) do
    scope = socket.assigns.current_scope

    case Events.create_event_type(scope, event_type) do
      {:ok, %EventType{} = event_type} ->
        event_type_contract = SyncMeEscrow.create_event_type(
          event_type.name,
          event_type.slug,
          event_type.description,
          event_type.duration_in_minutes,
          event_type.price)

          hex_code = Ethers.Utils.hex_encode(event_type_contract.data, include_prefix: false)
          create_event_call_data = %{
                "partner_wallet_address" => socket.assigns.current_scope.user.wallet_address,
                "to" => SyncMeEscrow.contract_address(),
                "data" => hex_code}

        {:noreply,
         socket
         |> push_event("event_created", create_event_call_data)
         #|> redirect(to: ~p"/partner/event_types")
         }

      {:error, changeset} ->
        IO.inspect(changeset)
        changeset = Map.put(changeset, :action, :validate)

        {:noreply,
         socket
         |> put_flash(:error, "Couldnt change event type.")
         |> assign(form: to_form(changeset))}
    end
  end
end
