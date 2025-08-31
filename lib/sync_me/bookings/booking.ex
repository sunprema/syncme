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
        :confirmed,
        :cancelled_by_guest,
        :cancelled_by_partner
      ],
      default: :confirmed

    field :video_conference_link, :string
    field :price_at_booking, :decimal
    field :duration_at_booking, :integer

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
      :video_conference_link,
      :price_at_booking,
      :duration_at_booking,
      :partner_id,
      :guest_user_id,
      :event_type_id
    ])
    |> validate_required([
      :start_time,
      :end_time,
      :video_conference_link,
      :price_at_booking,
      :duration_at_booking,
      :partner_id,
      :guest_user_id,
      :event_type_id
    ])
    |> validate_time_order()
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
