defmodule SyncMe.Partners.Partner do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "partners" do
    field :bio, :string
    field :syncme_link, :string

    belongs_to :user, SyncMe.Accounts.User
    has_many :event_types, SyncMe.Events.EventType
    has_many :availability_rules, SyncMe.Availability.AvailabilityRule
    has_many :availability_overrides, SyncMe.Availability.AvailabilityOverride
    has_many :bookings, SyncMe.Bookings.Booking

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(partner, attrs, user_scope) do
    partner
    |> cast(attrs, [:bio, :syncme_link])
    |> validate_required([:bio, :syncme_link])
    |> validate_length(:bio, min: 12, max: 160 )
    |> unique_constraint(:user_id, message: "Partner exists already.")
    |> unique_constraint(:syncme_link, message: "This syncme link is already in use, Try a different one.")
    |> put_change(:user_id, user_scope.user.id)
  end
end
