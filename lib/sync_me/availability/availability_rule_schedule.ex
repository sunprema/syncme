defmodule SyncMe.AvailabilityRule.Schedule do

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :day, :string
    field :checked, :boolean, default: false
    field :start, :time
    field :end, :time
  end

  def changeset(data, params) do
    data
    |> cast(params, [:day, :checked, :start, :end])
    |> validate_required([:day, :checked])
    |> validate_time_order()
  end


  # Custom validation function to compare start and end times
  defp validate_time_order(changeset) do
    # Get the cast time structs from the changeset
    start_time = get_field(changeset, :start)
    end_time = get_field(changeset, :end)

    # Check if both fields exist and are valid time structs
    if start_time && end_time do
      # Use Elixir's structural comparison for time structs
      if end_time > start_time do
        changeset
      else
        add_error(changeset, :end, "must be after the start time")
      end
    else
      # If start or end are nil, let other validations handle it
      changeset
    end
  end
end
