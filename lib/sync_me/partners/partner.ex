defmodule SyncMe.Partners.Partner do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "partners" do
    field :bio, :string
    field :syncme_link, :string
    field :stripe_account_id, :string

    #google calendar fields
    field :google_access_token, :string
    field :google_refresh_token, :string
    field :google_token_expires_at, :utc_datetime

    belongs_to :user, SyncMe.Accounts.User
    has_many :event_types, SyncMe.Events.EventType
    has_many :availability_rules, SyncMe.Availability.AvailabilityRule
    has_many :availability_overrides, SyncMe.Availability.AvailabilityOverride
    has_many :bookings, SyncMe.Bookings.Booking

    timestamps(type: :utc_datetime)
  end


  def changeset(partner, attrs, user_scope) do
    partner
    |> cast(attrs, [:bio, :syncme_link])
    |> validate_required([:bio, :syncme_link])
    |> validate_length(:bio, min: 12, max: 160)
    |> unique_constraint(:user_id, message: "Partner exists already.")
    |> unique_constraint(:syncme_link,
      message: "This syncme link is already in use, Try a different one."
    )
    |> put_change(:user_id, user_scope.user.id)
  end

  def changeset(partner, attrs) do
    partner
    |> cast(attrs, [:bio, :syncme_link])
    |> validate_required([:bio, :syncme_link])
    |> validate_length(:bio, min: 12, max: 160)
    |> unique_constraint(:user_id, message: "Partner exists already.")
    |> unique_constraint(:syncme_link,
      message: "This syncme link is already in use, Try a different one."
    )

  end



  def stripe_changeset(partner, attrs) do
    partner
    |> cast(attrs, [:stripe_account_id])
    |> validate_required([:stripe_account_id])

  end

  def google_token_changeset(partner, attrs) do
    partner
    |> cast(attrs, [:google_access_token, :google_refresh_token, :google_token_expires_at])
    |> validate_required([:google_access_token, :google_refresh_token, :google_token_expires_at])

  end

  def google_token_refresh_changeset(partner, attrs) do
    partner
    |> cast(attrs, [:google_access_token, :google_token_expires_at])
    |> validate_required([:google_access_token, :google_token_expires_at])

  end

end
