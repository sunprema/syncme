defmodule SyncMeWeb.PartnerCheck do
  use SyncMeWeb, :verified_routes

  alias SyncMe.Partners
  alias SyncMe.Accounts.Scope

  def on_mount(:assign_partner_to_scope, _params, _session, socket) do
    case Partners.load_partner(socket.assigns.current_scope) do
      %Partners.Partner{} = partner ->
        scope = Scope.put_partner(socket.assigns.current_scope, partner)
        Phoenix.Component.assign(socket, :current_scope, scope)

        {:cont,
         socket
         |> Phoenix.Component.assign(:current_scope, scope)}

      nil ->
        {:halt,
         socket
         |> Phoenix.LiveView.put_flash(
           :error,
           "You must have a Partner signup to access this page."
         )
         |> Phoenix.LiveView.redirect(to: ~p"/partner/signup")}
    end
  end
end
