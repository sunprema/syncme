defmodule SyncMeWeb.PartnerLive.Signup do
  use SyncMeWeb, :live_view

  alias SyncMe.Accounts.User

  def render(assigns) do
    ~H"""
     <Layouts.app flash={@flash} current_scope={@current_scope}>
       <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>
            Signup for Partner ship!
            <:subtitle>
            Partners can earn money
            </:subtitle>
          </.header>
        </div>
       </div>
     </Layouts.app>
    """

  end

end
