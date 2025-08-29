defmodule SyncMeWeb.PartnerLive.Signup do
  use SyncMeWeb, :live_view


  alias SyncMe.Partners.Partner


  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    partner_signup_change_set = SyncMe.Partners.Partner.changeset(%Partner{}, %{}, scope)
    form = to_form(partner_signup_change_set)
    {:ok,
      socket
      |> assign(form: form)

    }
  end

  def render(assigns) do
    ~H"""
     <Layouts.app flash={@flash} current_scope={@current_scope}>
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

          />

          <.input
            field={@form[:syncme_link]}
            label="Your syncme link"
            required
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
    </Layouts.app>
    """

  end

  def handle_event("validate", params, socket) do
    %{"partner" => partner} = params
    IO.inspect(partner)
    form =
      Partners.c
    {:noreply, socket}
  end

  def handle_event("save", unsigned_params, socket) do
    IO.inspect(unsigned_params)
    {:noreply, socket}
  end


end
