defmodule SyncMe.Events.EventType do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_types" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :duration_in_minutes, :integer
    field :price, :decimal
    field :is_active, :boolean, default: false
    field :partner_id, :binary_id
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_type, attrs, user_scope) do
    event_type
    |> cast(attrs, [:name, :slug, :description, :duration_in_minutes, :price, :is_active])
    |> validate_required([:name, :slug, :description, :duration_in_minutes, :price, :is_active])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:slug, name: :event_types_partner_id_slug_index)
  end
end
