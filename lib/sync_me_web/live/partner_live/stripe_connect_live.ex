# lib/sync_me_web/live/partner/stripe_connect_live.ex (New File)
defmodule SyncMeWeb.Partner.StripeConnectLive do
  use SyncMeWeb, :live_view

  alias SyncMe.Partners

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :onboarding_url, nil)}
  end

  def handle_event("connect-stripe", _params, socket) do
    partner = socket.assigns.current_scope.partner
    # Create a Stripe account unless one already exists
    {:ok, stripe_account_id} =
      case partner.stripe_account_id do
        nil ->
          with {:ok, account} <- Stripe.Account.create(%{"type" => "express"}),
               {:ok, updated_partner} <-
                 Partners.update_stripe_account_id(partner, %{
                   stripe_account_id: account.id
                 }) do
            {:ok, updated_partner.stripe_account_id}
          else
            {:error, reason} -> {:error, "Failed to create Stripe account: #{inspect(reason)}"}
          end

        id ->
          {:ok, id}
      end

    # Create a unique, single-use onboarding link for the partner
    base_url = SyncMeWeb.Endpoint.url()
    return_url = base_url <> ~p"/partner/home"
    # Redirect if link expires
    refresh_url = base_url <> ~p"/partner/stripe/connect"

    onboarding_link_params = %{
      account: stripe_account_id,
      return_url: return_url,
      refresh_url: refresh_url,
      type: "account_onboarding"
    }

    case Stripe.AccountLink.create(onboarding_link_params) do
      {:ok, %{url: url}} ->
        IO.inspect("Will redirect to #{url}", label: "STRIPE REPLIED")
        # Redirect the partner to Stripe to complete onboarding
        {:noreply, redirect(socket, external: url)}

      {:error, reason} ->
        IO.inspect("couldnt generate onboarding link #{inspect(reason)}", label: "STRIPE REPLIED")

        {:noreply,
         put_flash(socket, :error, "Could not generate onboarding link: #{inspect(reason)}")}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-semibold">Connect with Stripe</h1>
      <p>Connect your Stripe account to start accepting payments for your events.</p>
      <button class="btn btn-neutral" phx-click="connect-stripe">Connect with Stripe</button>
    </div>
    """
  end
end
