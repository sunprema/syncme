defmodule SyncMeWeb.UserLive.Login do
  use SyncMeWeb, :live_view

  alias SyncMe.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm space-y-4">
        <div class="text-center">
          <.header>
            <p class="tracking-normal text-md font-semibold">Log in to your SyncMe.Link account</p>
          </.header>
        </div>

        <div :if={local_mail_adapter?()} class="alert">
          <.icon name="hero-information-circle" class="size-6 shrink-0" />
          <div>
            <p>You are running the local mail adapter.</p>
            <p>
              To see sent emails, visit <.link href="/dev/mailbox" class="underline">the mailbox page</.link>.
            </p>
          </div>
        </div>

        <.form
          :let={f}
          for={@form}
          id="login_form_magic"
          action={~p"/users/log-in"}
          phx-submit="submit_magic"
        >
          <.input
            readonly={!!@current_scope}
            field={f[:email]}
            type="email"
            label="Email"
            autocomplete="username"
            required
            phx-mounted={JS.focus()}
          />
          <button class="btn btn-neutral w-full font-normal">
            Log in with email
          </button>
        </.form>

        <div class="divider divider-neutral/50 text-xs my-8">OR</div>
        <.link href={~p"/auth/google"} class="btn btn-outline w-full font-normal">
          Continue with Google
        </.link>
      </div>

      <footer class="footer sm:footer-horizontal absolute bottom-4 left-0 footer-center  text-base-content p-4">
        <aside>
          <p class="text-xs">
            By continuing, you agree to SyncMe.Link's
            <a><span class="font-semibold">Terms of Service</span></a>
            and <a><span class="font-semibold">Privacy Policy</span></a>
          </p>
        </aside>
      </footer>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  defp local_mail_adapter? do
    Application.get_env(:sync_me, SyncMe.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
