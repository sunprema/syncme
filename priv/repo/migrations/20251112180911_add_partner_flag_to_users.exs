defmodule SyncMe.Repo.Migrations.AddPartnerFlagToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_partner, :boolean, default: false
    end
  end
end
