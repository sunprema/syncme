defmodule SyncMe.Repo.Migrations.AddWalletAddressToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :wallet_address, :string
      add :wallet_type, :string, default: "base"
    end

    create unique_index(:users, [:wallet_address])
  end
end
