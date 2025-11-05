# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :sync_me, :scopes,
  user: [
    default: true,
    module: SyncMe.Accounts.Scope,
    assign_key: :current_scope,
    access_path: [:user, :id],
    schema_key: :user_id,
    schema_type: :binary_id,
    schema_table: :users,
    test_data_fixture: SyncMe.AccountsFixtures,
    test_setup_helper: :register_and_log_in_user
  ]

config :sync_me,
  ecto_repos: [SyncMe.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :sync_me, SyncMeWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: SyncMeWeb.ErrorHTML, json: SyncMeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SyncMe.PubSub,
  live_view: [signing_salt: "IAwPpg16"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :sync_me, SyncMe.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  sync_me: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  sync_me: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Google Auth config
config :ueberauth, Ueberauth,
  providers: [
    google:
      {Ueberauth.Strategy.Google,
       [
         default_scope:
           "email profile https://www.googleapis.com/auth/calendar.events https://www.googleapis.com/auth/calendar.freebusy",
         access_type: "offline",
         prompt: "consent"
       ]}
  ]

# Configure Ueberauth to use your Google OAuth credentials from environment variables.
config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Stripe integration
config :stripity_stripe,
  hackney_opts: [{:connect_timeout, 1000}, {:recv_timeout, 5000}],
  retries: [max_attempts: 3, base_backoff: 500, max_backoff: 2_000]

# Oban integration
config :sync_me, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10],
  repo: SyncMe.Repo

# Ethereum integration
config :ethereumex,
  url: "http://127.0.0.1:8545/"

config :sync_me, :blockchain,
  counter_contract_address: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
  #syncme_escrow_contract_address: "0xcD124Ab6d902Ba04006E01F173614544e8270580",
  syncme_escrow_contract_address: "0xCc8233726f4520b74766dEa8681d2a2f4789FFFA",
  usdc_coin: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
  admin: "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
  whale: "0xEe7aE85f2Fe2239E27D9c1E23fFFe168D63b4055",
  alice: "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc",
  bob: "0x90f79bf6eb2c4f870365e785982e1f101e93b906",
  paymaster_url: System.get_env("PAYMASTER_URL")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

IO.puts("CONFIG.EXS CALLED")
