defmodule SyncMe.PartnersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SyncMe.Partners` context.
  """

  @doc """
  Generate a partner.
  """
  def partner_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        bio: "some bio",
        syncme_link: "some syncme_link"
      })

    {:ok, partner} = SyncMe.Partners.create_partner(scope, attrs)
    partner
  end
end
