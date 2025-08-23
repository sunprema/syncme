defmodule SyncMe.Repo do
  use Ecto.Repo,
    otp_app: :sync_me,
    adapter: Ecto.Adapters.Postgres
end
