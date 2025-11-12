defmodule SyncMe.Partners do
  @moduledoc """
  The Partners context.
  """

  import Ecto.Query, warn: false
  alias SyncMe.Repo

  alias SyncMe.Partners.Partner
  alias SyncMe.Accounts.Scope

  def list_partners(%Scope{} = scope) do
    Repo.all_by(Partner, user_id: scope.user.id)
  end

  def get_partner(%Scope{user: user}) when not is_nil(user) do
    Repo.get_by(Partner, user_id: user.id)
  end

  def get_partner_by_user(user) when not is_nil(user) do
    Repo.get_by(Partner, user_id: user.id)
  end

  def create_partner(%Scope{} = scope, attrs) do
    with {:ok, partner = %Partner{}} <-
           %Partner{}
           |> Partner.changeset(Map.put(attrs, "timezone", attrs["timezone"]), scope)
           |> Repo.insert() do
      partner = Repo.preload(partner, [:user])
      Repo.update!(SyncMe.Accounts.User.upgrade_partner_changeset(partner.user, true))
      {:ok, partner}
    end
  end

  def update_partner(%Scope{partner: partner} = scope, attrs) when not is_nil(partner) do
    with {:ok, partner = %Partner{}} <-
           partner
           |> Partner.changeset(attrs, scope)
           |> Repo.update() do
      {:ok, partner}
    end
  end

  def update_partner(partner, attrs) when not is_nil(partner) do
    with {:ok, partner = %Partner{}} <-
           partner
           |> Partner.changeset(attrs)
           |> Repo.update() do
      {:ok, partner}
    end
  end

  def update_calendar_tokens(partner, attrs) when not is_nil(partner) do
    partner
    |> Partner.google_token_changeset(attrs)
    |> Repo.update()
  end

  def update_stripe_account_id(partner, attrs) when not is_nil(partner) do
    with {:ok, partner_updated} <-
           partner
           |> Partner.stripe_changeset(attrs)
           |> Repo.update() do
      {:ok, partner_updated}
    end
  end

  @doc """
  Deletes a partner.

  ## Examples

      iex> delete_partner(scope, partner)
      {:ok, %Partner{}}

      iex> delete_partner(scope, partner)
      {:error, %Ecto.Changeset{}}

  """
  def delete_partner(%Scope{} = scope, %Partner{} = partner) do
    true = partner.user_id == scope.user.id

    with {:ok, partner = %Partner{}} <-
           Repo.delete(partner) do
      {:ok, partner}
    end
  end

  def change_partner(%Scope{} = scope, %Partner{} = partner, attrs \\ %{}) do
    Partner.changeset(partner, attrs, scope)
  end

  def load_partner(%Scope{user: user}) when not is_nil(user) do
    user = Repo.preload(user, partner: [:event_types, :availability_rules])
    user.partner
  end

  def get_partner_by_syncme_link(syncme_link) do
    case Repo.get_by(Partner, syncme_link: syncme_link) do
      nil ->
        nil

      %Partner{} = partner ->
        Repo.preload(partner, [:event_types, :availability_rules])
    end
  end
end
