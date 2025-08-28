defmodule SyncMe.Repo.Migrations.CreateAvailabilityOverrides do
  use Ecto.Migration

  def change do
    create table(:availability_overrides, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date
      add :start_time, :time
      add :end_time, :time
      add :is_available, :boolean, default: false, null: false
      add :partner_id, references(:partners, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:availability_overrides, [:partner_id])
  end
end
