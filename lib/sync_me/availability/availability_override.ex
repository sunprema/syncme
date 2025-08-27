defmodule SyncMe.Availability.AvailabilityOverride do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "availability_overrides" do
    field :date, :date
    field :start_time, :time
    field :end_time, :time
    field :is_available, :boolean, default: false
    field :partner_id, :binary_id
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(availability_override, attrs, user_scope) do
    availability_override
    |> cast(attrs, [:date, :start_time, :end_time, :is_available])
    |> validate_required([:date, :start_time, :end_time, :is_available])
    |> put_change(:user_id, user_scope.user.id)
  end
end
