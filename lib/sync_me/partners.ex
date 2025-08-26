defmodule SyncMe.Partners do
  @moduledoc """
  The Partners context.
  """

  import Ecto.Query, warn: false
  alias SyncMe.Repo

  alias SyncMe.Partners.Partner
  alias SyncMe.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any partner changes.

  The broadcasted messages match the pattern:

    * {:created, %Partner{}}
    * {:updated, %Partner{}}
    * {:deleted, %Partner{}}

  """
  def subscribe_partners(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SyncMe.PubSub, "user:#{key}:partners")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(SyncMe.PubSub, "user:#{key}:partners", message)
  end

  @doc """
  Returns the list of partners.

  ## Examples

      iex> list_partners(scope)
      [%Partner{}, ...]

  """
  def list_partners(%Scope{} = scope) do
    Repo.all_by(Partner, user_id: scope.user.id)
  end

  @doc """
  Gets a single partner.

  Raises `Ecto.NoResultsError` if the Partner does not exist.

  ## Examples

      iex> get_partner!(scope, 123)
      %Partner{}

      iex> get_partner!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_partner!(%Scope{} = scope, id) do
    Repo.get_by!(Partner, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a partner.

  ## Examples

      iex> create_partner(scope, %{field: value})
      {:ok, %Partner{}}

      iex> create_partner(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_partner(%Scope{} = scope, attrs) do
    with {:ok, partner = %Partner{}} <-
           %Partner{}
           |> Partner.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, partner})
      {:ok, partner}
    end
  end

  @doc """
  Updates a partner.

  ## Examples

      iex> update_partner(scope, partner, %{field: new_value})
      {:ok, %Partner{}}

      iex> update_partner(scope, partner, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_partner(%Scope{} = scope, %Partner{} = partner, attrs) do
    true = partner.user_id == scope.user.id

    with {:ok, partner = %Partner{}} <-
           partner
           |> Partner.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, partner})
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
      broadcast(scope, {:deleted, partner})
      {:ok, partner}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking partner changes.

  ## Examples

      iex> change_partner(scope, partner)
      %Ecto.Changeset{data: %Partner{}}

  """
  def change_partner(%Scope{} = scope, %Partner{} = partner, attrs \\ %{}) do
    true = partner.user_id == scope.user.id

    Partner.changeset(partner, attrs, scope)
  end
end
