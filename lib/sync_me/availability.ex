defmodule SyncMe.Availability do
  @moduledoc """
  The Availability context.
  """

  import Ecto.Query, warn: false
  alias SyncMe.Repo

  alias SyncMe.Availability.AvailabilityRule
  alias SyncMe.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any availability_rule changes.

  The broadcasted messages match the pattern:

    * {:created, %AvailabilityRule{}}
    * {:updated, %AvailabilityRule{}}
    * {:deleted, %AvailabilityRule{}}

  """
  def subscribe_availability_rules(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SyncMe.PubSub, "user:#{key}:availability_rules")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(SyncMe.PubSub, "user:#{key}:availability_rules", message)
  end

  @doc """
  Returns the list of availability_rules.

  ## Examples

      iex> list_availability_rules(scope)
      [%AvailabilityRule{}, ...]

  """
  def list_availability_rules(%Scope{} = scope) do
    Repo.all_by(AvailabilityRule, user_id: scope.user.id)
  end

  @doc """
  Gets a single availability_rule.

  Raises `Ecto.NoResultsError` if the Availability rule does not exist.

  ## Examples

      iex> get_availability_rule!(scope, 123)
      %AvailabilityRule{}

      iex> get_availability_rule!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_availability_rule!(%Scope{} = scope, id) do
    Repo.get_by!(AvailabilityRule, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a availability_rule.

  ## Examples

      iex> create_availability_rule(scope, %{field: value})
      {:ok, %AvailabilityRule{}}

      iex> create_availability_rule(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_availability_rule(%Scope{} = scope, attrs) do
    with {:ok, availability_rule = %AvailabilityRule{}} <-
           %AvailabilityRule{}
           |> AvailabilityRule.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, availability_rule})
      {:ok, availability_rule}
    end
  end

  @doc """
  Updates a availability_rule.

  ## Examples

      iex> update_availability_rule(scope, availability_rule, %{field: new_value})
      {:ok, %AvailabilityRule{}}

      iex> update_availability_rule(scope, availability_rule, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_availability_rule(%Scope{} = scope, %AvailabilityRule{} = availability_rule, attrs) do
    true = availability_rule.user_id == scope.user.id

    with {:ok, availability_rule = %AvailabilityRule{}} <-
           availability_rule
           |> AvailabilityRule.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, availability_rule})
      {:ok, availability_rule}
    end
  end

  @doc """
  Deletes a availability_rule.

  ## Examples

      iex> delete_availability_rule(scope, availability_rule)
      {:ok, %AvailabilityRule{}}

      iex> delete_availability_rule(scope, availability_rule)
      {:error, %Ecto.Changeset{}}

  """
  def delete_availability_rule(%Scope{} = scope, %AvailabilityRule{} = availability_rule) do
    true = availability_rule.user_id == scope.user.id

    with {:ok, availability_rule = %AvailabilityRule{}} <-
           Repo.delete(availability_rule) do
      broadcast(scope, {:deleted, availability_rule})
      {:ok, availability_rule}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking availability_rule changes.

  ## Examples

      iex> change_availability_rule(scope, availability_rule)
      %Ecto.Changeset{data: %AvailabilityRule{}}

  """
  def change_availability_rule(%Scope{} = scope, %AvailabilityRule{} = availability_rule, attrs \\ %{}) do
    true = availability_rule.user_id == scope.user.id

    AvailabilityRule.changeset(availability_rule, attrs, scope)
  end

  alias SyncMe.Availability.AvailabilityOverride
  alias SyncMe.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any availability_override changes.

  The broadcasted messages match the pattern:

    * {:created, %AvailabilityOverride{}}
    * {:updated, %AvailabilityOverride{}}
    * {:deleted, %AvailabilityOverride{}}

  """
  def subscribe_availability_overrides(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SyncMe.PubSub, "user:#{key}:availability_overrides")
  end

  @doc """
  Returns the list of availability_overrides.

  ## Examples

      iex> list_availability_overrides(scope)
      [%AvailabilityOverride{}, ...]

  """
  def list_availability_overrides(%Scope{} = scope) do
    Repo.all_by(AvailabilityOverride, user_id: scope.user.id)
  end

  @doc """
  Gets a single availability_override.

  Raises `Ecto.NoResultsError` if the Availability override does not exist.

  ## Examples

      iex> get_availability_override!(scope, 123)
      %AvailabilityOverride{}

      iex> get_availability_override!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_availability_override!(%Scope{} = scope, id) do
    Repo.get_by!(AvailabilityOverride, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a availability_override.

  ## Examples

      iex> create_availability_override(scope, %{field: value})
      {:ok, %AvailabilityOverride{}}

      iex> create_availability_override(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_availability_override(%Scope{} = scope, attrs) do
    with {:ok, availability_override = %AvailabilityOverride{}} <-
           %AvailabilityOverride{}
           |> AvailabilityOverride.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, availability_override})
      {:ok, availability_override}
    end
  end

  @doc """
  Updates a availability_override.

  ## Examples

      iex> update_availability_override(scope, availability_override, %{field: new_value})
      {:ok, %AvailabilityOverride{}}

      iex> update_availability_override(scope, availability_override, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_availability_override(%Scope{} = scope, %AvailabilityOverride{} = availability_override, attrs) do
    true = availability_override.user_id == scope.user.id

    with {:ok, availability_override = %AvailabilityOverride{}} <-
           availability_override
           |> AvailabilityOverride.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, availability_override})
      {:ok, availability_override}
    end
  end

  @doc """
  Deletes a availability_override.

  ## Examples

      iex> delete_availability_override(scope, availability_override)
      {:ok, %AvailabilityOverride{}}

      iex> delete_availability_override(scope, availability_override)
      {:error, %Ecto.Changeset{}}

  """
  def delete_availability_override(%Scope{} = scope, %AvailabilityOverride{} = availability_override) do
    true = availability_override.user_id == scope.user.id

    with {:ok, availability_override = %AvailabilityOverride{}} <-
           Repo.delete(availability_override) do
      broadcast(scope, {:deleted, availability_override})
      {:ok, availability_override}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking availability_override changes.

  ## Examples

      iex> change_availability_override(scope, availability_override)
      %Ecto.Changeset{data: %AvailabilityOverride{}}

  """
  def change_availability_override(%Scope{} = scope, %AvailabilityOverride{} = availability_override, attrs \\ %{}) do
    true = availability_override.user_id == scope.user.id

    AvailabilityOverride.changeset(availability_override, attrs, scope)
  end
end
