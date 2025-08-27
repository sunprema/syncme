defmodule SyncMe.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias SyncMe.Repo

  alias SyncMe.Events.EventType
  alias SyncMe.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any event_type changes.

  The broadcasted messages match the pattern:

    * {:created, %EventType{}}
    * {:updated, %EventType{}}
    * {:deleted, %EventType{}}

  """
  def subscribe_event_types(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SyncMe.PubSub, "user:#{key}:event_types")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(SyncMe.PubSub, "user:#{key}:event_types", message)
  end

  @doc """
  Returns the list of event_types.

  ## Examples

      iex> list_event_types(scope)
      [%EventType{}, ...]

  """
  def list_event_types(%Scope{} = scope) do
    Repo.all_by(EventType, user_id: scope.user.id)
  end

  @doc """
  Gets a single event_type.

  Raises `Ecto.NoResultsError` if the Event type does not exist.

  ## Examples

      iex> get_event_type!(scope, 123)
      %EventType{}

      iex> get_event_type!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_event_type!(%Scope{} = scope, id) do
    Repo.get_by!(EventType, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a event_type.

  ## Examples

      iex> create_event_type(scope, %{field: value})
      {:ok, %EventType{}}

      iex> create_event_type(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event_type(%Scope{} = scope, attrs) do
    with {:ok, event_type = %EventType{}} <-
           %EventType{}
           |> EventType.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, event_type})
      {:ok, event_type}
    end
  end

  @doc """
  Updates a event_type.

  ## Examples

      iex> update_event_type(scope, event_type, %{field: new_value})
      {:ok, %EventType{}}

      iex> update_event_type(scope, event_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event_type(%Scope{} = scope, %EventType{} = event_type, attrs) do
    true = event_type.user_id == scope.user.id

    with {:ok, event_type = %EventType{}} <-
           event_type
           |> EventType.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, event_type})
      {:ok, event_type}
    end
  end

  @doc """
  Deletes a event_type.

  ## Examples

      iex> delete_event_type(scope, event_type)
      {:ok, %EventType{}}

      iex> delete_event_type(scope, event_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event_type(%Scope{} = scope, %EventType{} = event_type) do
    true = event_type.user_id == scope.user.id

    with {:ok, event_type = %EventType{}} <-
           Repo.delete(event_type) do
      broadcast(scope, {:deleted, event_type})
      {:ok, event_type}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event_type changes.

  ## Examples

      iex> change_event_type(scope, event_type)
      %Ecto.Changeset{data: %EventType{}}

  """
  def change_event_type(%Scope{} = scope, %EventType{} = event_type, attrs \\ %{}) do
    true = event_type.user_id == scope.user.id

    EventType.changeset(event_type, attrs, scope)
  end
end
