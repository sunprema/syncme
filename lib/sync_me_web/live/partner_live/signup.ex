defmodule SyncMeWeb.PartnerLive.Signup do
  use SyncMeWeb, :live_view


  alias SyncMe.Partners


  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    partner_signup_change_set = Partners.change_partner(scope, %Partners.Partner{}, %{})
    form = to_form(partner_signup_change_set)
    {:ok,
      socket
      |> assign(form: form)

    }
  end

  def render(assigns) do
    ~H"""
     <Layouts.partner_layout flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>
            Sign up as a Partner
            <:subtitle>
              Already registered?
              <.link navigate={~p"/users/log-in"} class="font-semibold text-brand hover:underline">
                Log in
              </.link>
              to your account now.
            </:subtitle>
          </.header>
        </div>

        <.form for={@form} id="partner_signup_form"  phx-submit="save" phx-change="validate">
          <.input
            field={@form[:bio]}
            type="textarea"
            label="Bio"
            required
            phx-debounce="200"

          />

          <.input
            field={@form[:syncme_link]}
            label="Your syncme link"
            required
            phx-debounce="200"
            phx-mounted={JS.focus()}
          />

          <button phx-disable-with="Creating account..." class="btn btn-neutral w-full font-normal">
            Sign up as partner
          </button>
        </.form>

        <footer class="footer sm:footer-horizontal absolute bottom-4 left-0 footer-center  text-base-content p-4">
          <aside>
            <p class="text-xs">
              By continuing, you agree to SyncMe.Link's
              <a><span class="font-semibold">Terms of Service</span></a>
              and <a><span class="font-semibold">Privacy Policy</span></a>
            </p>
          </aside>
        </footer>
      </div>
    </Layouts.partner_layout>
    """

  end

  def handle_event("validate", %{"partner" => partner} = _params, socket) do
    scope = socket.assigns.current_scope
    change_set = Partners.change_partner(scope, %Partners.Partner{}, partner)
    change_set = Map.put(change_set, :action, :validate)
    {:noreply ,
    assign(socket, form: to_form(change_set))
  }

  end

  def handle_event("save", %{"partner" => partner} = _params, socket) do
    scope = socket.assigns.current_scope
   case Partners.create_partner(scope, partner) do
    {:ok, partner} ->
      {:noreply,
      socket
      |> put_flash(:info, "Partner signup success - id #{partner.id}!")
      |> redirect(to: ~p"/partner/home")
      }
    {:error, changeset} ->
      IO.inspect(changeset)
      changeset = Map.put(changeset, :action, :validate)
      {:noreply ,
        socket
        |> assign( form: to_form(changeset))
    }
   end

  end


end
