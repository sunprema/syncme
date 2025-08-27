defmodule SyncMe.AvailabilityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SyncMe.Availability` context.
  """

  @doc """
  Generate a availability_rule.
  """
  def availability_rule_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        day_of_week: 42,
        end_time: ~T[14:00:00],
        start_time: ~T[14:00:00]
      })

    {:ok, availability_rule} = SyncMe.Availability.create_availability_rule(scope, attrs)
    availability_rule
  end

  @doc """
  Generate a availability_override.
  """
  def availability_override_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        date: ~D[2025-08-26],
        end_time: ~T[14:00:00],
        is_available: true,
        start_time: ~T[14:00:00]
      })

    {:ok, availability_override} = SyncMe.Availability.create_availability_override(scope, attrs)
    availability_override
  end
end
