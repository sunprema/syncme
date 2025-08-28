defmodule SyncMe.Repo.Migrations.CreateAvailabilityRules do
  use Ecto.Migration

  def change do
    create table(:availability_rules, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :day_of_week, :integer
      add :start_time, :time
      add :end_time, :time
      add :partner_id, references(:partners, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:availability_rules, [:partner_id])
  end
end
