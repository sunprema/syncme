defmodule SyncMe.Events.EventType do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :slug, :description, :duration_in_minutes, :price]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_types" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :duration_in_minutes, :integer
    field :price, :integer
    field :tx_hash, :string
    field :currency, :string, default: "usd"
    field :is_active, :boolean, default: true

    belongs_to :partner, SyncMe.Partners.Partner
    has_many :bookings, SyncMe.Bookings.Booking

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_type, attrs) do
    event_type
    |> cast(attrs, [
      :name,
      :slug,
      :description,
      :duration_in_minutes,
      :price,
      :is_active,
      :partner_id
    ])
    |> validate_required([
      :name,
      :duration_in_minutes,
      :price,
      :partner_id
    ])
    |> validate_number(:duration_in_minutes, greater_than: 0)
    |> unique_constraint(:slug, name: :event_types_partner_id_slug_index)
  end

  @doc false
  def txhash_changeset(event_type, attrs) do
    event_type
    |> cast(attrs, [:tx_hash])
    |> validate_required([:tx_hash])
  end
end
