defmodule SyncMe.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias SyncMe.Repo

  alias SyncMe.Events.EventType
  alias SyncMe.Accounts.Scope

  def list_event_types(%Scope{user: user}) when not is_nil(user) do
    query =
      from r in EventType,
        join: p in assoc(r, :partner),
        where: p.user_id == ^user.id,
        select: r

    Repo.all(query)
  end

  def get_event_type!(%Scope{user: user}, id) do
    query =
      from r in EventType,
        join: p in assoc(r, :partner),
        where: p.user_id == ^user.id and r.id == ^id,
        select: r

    Repo.one!(query)
  end

  def create_event_type(%Scope{user: user}, attrs) when not is_nil(user) do
    with partner <- Repo.get_by(Partner, user_id: user.id),
         true <- !is_nil(partner) do
      attrs_with_partner_id = Map.put(attrs, "partner_id", partner.id)

      %EventType{}
      |> EventType.changeset(attrs_with_partner_id)
      |> Repo.insert()
    else
      false -> {:error, :partner_not_found}
    end
  end

  def update_event_type(%Scope{} = scope, %EventType{} = event_type, attrs) do
    with :ok <- verify_event_type_ownership(scope, event_type),
         {:ok, changeset} <-
           event_type
           |> EventType.changeset(attrs)
           |> Ecto.Changeset.apply_action(:update) do
      Repo.update(changeset)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def delete_event_type(%Scope{} = scope, %EventType{} = event_type) do
    with :ok <- verify_event_type_ownership(scope, event_type) do
      Repo.delete(event_type)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp verify_event_type_ownership(%Scope{user: user}, event_type) when not is_nil(user) do
    partner = Repo.get_by(Partner, user_id: user.id)

    if partner && partner.id == event_type.partner_id do
      :ok
    else
      {:error, :not_found_or_unauthorized}
    end
  end

  defp verify_event_type_ownership(%Scope{user: nil}, _rule) do
    {:error, :user_not_authenticated}
  end
end
