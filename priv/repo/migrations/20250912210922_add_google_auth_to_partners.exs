defmodule SyncMe.Repo.Migrations.AddGoogleAuthToPartners do
  use Ecto.Migration

  def up do
    alter table(:partners) do
      add :google_access_token, :string
      add :google_refresh_token, :string
      add :google_token_expires_at, :utc_datetime
    end
  end
  def change do
    alter table(:partners) do
      remove :google_access_token
      remove :google_refresh_token
      remove :google_token_expires_at
    end
  end

end
