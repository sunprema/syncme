defmodule SyncMe.Availability.AvailabilityRule do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "availability_rules" do
    field :day_of_week, :integer
    field :start_time, :time
    field :end_time, :time
    field :partner_id, :binary_id
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(availability_rule, attrs, user_scope) do
    availability_rule
    |> cast(attrs, [:day_of_week, :start_time, :end_time])
    |> validate_required([:day_of_week, :start_time, :end_time])
    |> put_change(:user_id, user_scope.user.id)
  end
end
