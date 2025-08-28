defmodule SyncMe.Billing do
  @moduledoc """
  The Billing context.
  """

  import Ecto.Query, warn: false
  alias SyncMe.Repo

  alias SyncMe.Billing.Transaction
  alias SyncMe.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any transaction changes.

  The broadcasted messages match the pattern:

    * {:created, %Transaction{}}
    * {:updated, %Transaction{}}
    * {:deleted, %Transaction{}}

  """
  def subscribe_transactions(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SyncMe.PubSub, "user:#{key}:transactions")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(SyncMe.PubSub, "user:#{key}:transactions", message)
  end

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions(scope)
      [%Transaction{}, ...]

  """

  def list_partner_transactions(%Scope{} = scope) do
    Repo.all_by(Transaction, partner_id: scope.user.id)
  end

  def list_guest_transactions(%Scope{} = scope) do
    Repo.all_by(Transaction, partner_id: scope.user.id)
  end

  def list_transactions(%Scope{} = scope) do
    Repo.all_by(Transaction, user_id: scope.user.id)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(scope, 123)
      %Transaction{}

      iex> get_transaction!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(%Scope{} = scope, id) do
    Repo.get_by!(Transaction, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(scope, %{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(%Scope{} = scope, attrs) do
    with {:ok, transaction = %Transaction{}} <-
           %Transaction{}
           |> Transaction.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, transaction})
      {:ok, transaction}
    end
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(scope, transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(scope, transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Scope{} = scope, %Transaction{} = transaction, attrs) do
    true = transaction.user_id == scope.user.id

    with {:ok, transaction = %Transaction{}} <-
           transaction
           |> Transaction.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, transaction})
      {:ok, transaction}
    end
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(scope, transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(scope, transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Scope{} = scope, %Transaction{} = transaction) do
    true = transaction.user_id == scope.user.id

    with {:ok, transaction = %Transaction{}} <-
           Repo.delete(transaction) do
      broadcast(scope, {:deleted, transaction})
      {:ok, transaction}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(scope, transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Scope{} = scope, %Transaction{} = transaction, attrs \\ %{}) do
    true = transaction.user_id == scope.user.id

    Transaction.changeset(transaction, attrs, scope)
  end
end
