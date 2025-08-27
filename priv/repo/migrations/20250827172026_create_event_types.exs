defmodule SyncMe.Repo.Migrations.CreateEventTypes do
  use Ecto.Migration

  def change do
    create table(:event_types, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :slug, :string
      add :description, :text
      add :duration_in_minutes, :integer
      add :price, :decimal
      add :is_active, :boolean, default: true, null: false
      add :partner_id, references(:partners, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:event_types, [:user_id])
    create index(:event_types, [:partner_id])

    create unique_index(:event_types, [:partner_id, :slug], name: :event_types_partner_id_slug_index)

  end
end
