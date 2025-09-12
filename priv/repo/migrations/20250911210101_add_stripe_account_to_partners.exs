defmodule SyncMe.Repo.Migrations.AddStripeAccountToPartners do
  use Ecto.Migration

  def up do
    alter table(:partners) do
      add :stripe_account_id, :string, null: true
    end

    create unique_index(:partners, [:stripe_account_id])
  end

  def down do
    alter table(:partners) do
      remove :stripe_account_id
    end
  end
end
