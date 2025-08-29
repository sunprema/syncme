defmodule SyncMe.Billing do
  @moduledoc """
  The Billing context.
  """

  import Ecto.Query, warn: false
  alias SyncMe.Repo

  alias SyncMe.Billing.Transaction
  alias SyncMe.Accounts.Scope
  alias SyncMe.Bookings.Booking

  def create_transaction!(user, attrs, %Booking{} = booking) when not is_nil(user) do
    partner = Repo.get_by(Partner, user_id: user.id)

    cond do
      is_nil(partner) ->
        if booking.guest_user_id == user.id do
          %Transaction{}
          |> Transaction.changeset(attrs)
          |> Repo.insert!()
        else
          {:error, :booking_not_authorized}
        end

      true ->
        {:error, :booking_not_authorized}
    end
  end

  def create_transaction(%Scope{user: nil}, _attrs) do
    {:error, :booking_not_authorized}
  end
end
