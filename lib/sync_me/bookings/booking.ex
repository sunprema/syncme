defmodule SyncMe.Bookings.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bookings" do
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    field :status, :string
    field :video_conference_link, :string
    field :price_at_booking, :decimal
    field :duration_at_booking, :integer
    field :partner_id, :binary_id
    field :guest_user_id, :binary_id
    field :event_type_id, :binary_id
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(booking, attrs, user_scope) do
    booking
    |> cast(attrs, [:start_time, :end_time, :status, :video_conference_link, :price_at_booking, :duration_at_booking])
    |> validate_required([:start_time, :end_time, :status, :video_conference_link, :price_at_booking, :duration_at_booking])
    |> put_change(:user_id, user_scope.user.id)
  end
end
