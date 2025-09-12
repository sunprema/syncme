defmodule SyncMeWeb.SettingsLive.SettingsComponent do
  use SyncMeWeb, :live_component
  alias SyncMe.Partners

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id="partner_signup_form"
        phx-debounce="2000"
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <.input
          field={@form[:bio]}
          type="textarea"
          rows="12"
          label="Bio"
          required
        />
        <.input
          field={@form[:syncme_link]}
          label="Your syncme link"
          required
          phx-debounce="2000"
          phx-mounted={JS.focus()}
        />

        <button phx-disable-with="Creating account..." class="btn btn-neutral w-full font-normal">
          Update
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
      partner_change_set = Partners.change_partner(scope, partner, %{})
      form = to_form(partner_change_set)

      {:ok,
       socket
       |> assign(:current_scope, scope)
       |> assign(partner: partner)
       |> assign(form: form)}
    end
  end

  @impl true
  def handle_event("validate", %{"partner" => partner} = _params, socket) do
    scope = socket.assigns.current_scope
    change_set = Partners.change_partner(scope, %Partners.Partner{}, partner)
    change_set = Map.put(change_set, :action, :validate)
    {:noreply, assign(socket, form: to_form(change_set))}
  end

  @impl true
  def handle_event("save", %{"partner" => partner} = _params, socket) do
    scope = socket.assigns.current_scope

    case Partners.update_partner(scope,partner) do
      {:ok, _partner} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profile updated.")
         |> redirect(to: ~p"/partner/settings")}

      {:error, changeset} ->
        IO.inspect(changeset)
        changeset = Map.put(changeset, :action, :validate)

        {:noreply,
         socket
         |> put_flash(:error, "Couldnt change settings.")
         |> assign(form: to_form(changeset))}
    end
  end
end
