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



  def create_partner(%Scope{} = scope, attrs) do
    with {:ok, partner = %Partner{}} <-
           %Partner{}
           |> Partner.changeset(attrs, scope)
           |> Repo.insert() do
        {:ok, partner}
    end
  end

  def update_partner(%Scope{} = scope, %Partner{} = partner, attrs) do

    with {:ok, partner = %Partner{}} <-
           partner
           |> Partner.changeset(attrs, scope)
           |> Repo.update() do

      {:ok, partner}
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
    user = Repo.preload(user, [:partner])
    user.partner
  end

end
