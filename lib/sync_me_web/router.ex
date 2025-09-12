defmodule SyncMeWeb.Router do
  use SyncMeWeb, :router

  import SyncMeWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SyncMeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", SyncMeWeb do
    pipe_through :browser
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/", SyncMeWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/privacy", PrivacyAndTOSController, :privacy
    get "/terms_of_service", PrivacyAndTOSController, :tos
    get "/:syncme_link", GuestUserHomeController, :home
  end

  scope "/", SyncMeWeb do
    pipe_through [:browser, :maybe_authenticated_user]

    get "/book_event/new/login/:event_type_id/:encodedTimeSelected",
        BookingEventController,
        :new_session

    live_session :maybe_authenticated_user,
      on_mount: [{SyncMeWeb.UserAuth, :maybe_authenticated}] do
      live "/book_event/new/:event_type_id", BookingEvent, :new
      live "/book_event/details/:event_type_id", BookingEvent, :details
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", SyncMeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:sync_me, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SyncMeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SyncMeWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SyncMeWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
      live "/user/home", UserHome.Index, :index
      live "/partner/signup", PartnerLive.Signup, :new

      get "/book_event/return/login/:event_type_id/:encodedTimeSelected",
          BookingEventController,
          :return_session

      live "/book_event/auth/details/:event_type_id/:encodedTimeSelected", BookingEvent, :details
      live "/booking/success", BookingCompletionLive, :success
      live "/booking/view/:booking_id", BookingView, :show
    end

    live_session :partner_flow,
      on_mount: [
        {SyncMeWeb.UserAuth, :require_authenticated},
        {SyncMeWeb.PartnerCheck, :assign_partner_to_scope}
      ] do
      live "/partner/home", EventTypesLive.Index, :index
      live "/partner/event_types", EventTypesLive.Index, :index
      live "/partner/event_types/new", EventTypesLive.Show, :new
      live "/partner/event_types/:id/edit", EventTypesLive.Show, :edit
      live "/partner/settings", SettingsLive
      live "/partner/availability", AvailabilityLive.Show, :show

      # all bookings
      live "/partner/bookings", BookingsLive.Index, :index
      live "/partner/bookings/upcoming", BookingsLive.Index, :upcoming
      live "/partner/bookings/unconfirmed", BookingsLive.Index, :unconfirmed
      live "/partner/bookings/cancelled", BookingsLive.Index, :cancelled
      live "/partner/insights", InsightsLive.Dashboard, :dashboard
      live "/partner/booking/view/:booking_id", BookingView, :show

      # Stripe Connect
      live "/partner/stripe/connect", Partner.StripeConnectLive, :new
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", SyncMeWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{SyncMeWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
