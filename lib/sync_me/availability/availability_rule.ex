defmodule SyncMe.Availability.AvailabilityRule do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "availability_rules" do
    field :day_of_week, :integer
    field :start_time, :time
    field :end_time, :time
    belongs_to :partner, SyncMe.Partners.Partner

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(availability_rule, attrs) do
    availability_rule
    |> cast(attrs, [:day_of_week, :start_time, :end_time, :partner_id])
    |> validate_required([:day_of_week, :start_time, :end_time, :partner_id])
    |> validate_inclusion(:day_of_week, 1..7,
      message: "must be between 1 (Monday) and 7 (Sunday)"
    )
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
