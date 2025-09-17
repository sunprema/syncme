defmodule SyncMe.Repo.Migrations.AddTimezoneToPartners do
  use Ecto.Migration

  def change do
    alter table(:partners) do
      add :timezone, :string, null: false, default: "Etc/UTC"
    end
  end
end
