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
    belongs_to :partner, SyncMe.Partners.Partner

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(availability_override, attrs) do
    availability_override
    |> cast(attrs, [:date, :start_time, :end_time, :is_available, :partner_id])
    |> validate_required([:date, :start_time, :end_time, :is_available, :partner_id])
    |> validate_time_order()
  end

  # TODO: can be moved to a shared helper, as both availability_rules and availability_overrides are using this
  # Custom validation to ensure end_time is after start_time
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
