defmodule SyncMe.Repo.Migrations.CreatePartners do
  use Ecto.Migration

  def change do
    create table(:partners, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :bio, :string
      add :syncme_link, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      timestamps(type: :utc_datetime)
    end

    create index(:partners, [:user_id])
    create index(:partners, [:syncme_link])

  end
end
