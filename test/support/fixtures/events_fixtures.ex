defmodule SyncMe.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SyncMe.Events` context.
  """

  @doc """
  Generate a event_type.
  """
  def event_type_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        duration_in_minutes: 42,
        is_active: true,
        name: "some name",
        price: "120.5",
        slug: "some slug"
      })

    {:ok, event_type} = SyncMe.Events.create_event_type(scope, attrs)
    event_type
  end
end
