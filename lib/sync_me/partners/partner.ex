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

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(partner, attrs, user_scope) do
    partner
    |> cast(attrs, [:bio, :syncme_link])
    |> validate_required([:bio, :syncme_link])
    |> put_change(:user_id, user_scope.user.id)
  end
end
