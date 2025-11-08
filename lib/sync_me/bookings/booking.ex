defmodule SyncMe.Bookings.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bookings" do
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime

    field :status, Ecto.Enum,
      values: [
        :pending,
        :confirmed,
        :cancelled_by_guest,
        :cancelled_by_partner
      ],
      default: :confirmed

    field :guest_email, :string
    field :guest_name, :string
    field :video_conference_link, :string
    field :price_at_booking, :decimal
    field :duration_at_booking, :integer
    field :tx_hash, :string
    field :contract_booking_id, :decimal
    field :chain_id, :string

    belongs_to :event_type, SyncMe.Events.EventType
    belongs_to :partner, SyncMe.Partners.Partner
    belongs_to :guest_user, SyncMe.Accounts.User, foreign_key: :guest_user_id

    has_one :transaction, SyncMe.Billing.Transaction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(booking, attrs \\ %{}) do
    booking
    |> cast(attrs, [
      :start_time,
      :end_time,
      :status,
      :price_at_booking,
      :duration_at_booking,
      :partner_id,
      :guest_user_id,
      :event_type_id
    ])
    |> validate_required([
      :start_time,
      :end_time,
      :price_at_booking,
      :duration_at_booking,
      :partner_id,
      :guest_user_id,
      :event_type_id
    ])
    |> validate_time_order()
  end

  @doc false
  def onchain_changeset(booking, attrs) do
    booking
    |> cast(attrs, [:tx_hash, :contract_booking_id])
    |> validate_required([:tx_hash, :contract_booking_id])
  end

  defp validate_time_order(changeset) do
    start_time = get_field(changeset, :start_time)
    end_time = get_field(changeset, :end_time)

    if start_time && end_time && Time.compare(end_time, start_time) != :gt do
      add_error(changeset, :end_time, "must be after start time")
    else
      changeset
    end
  end
end
