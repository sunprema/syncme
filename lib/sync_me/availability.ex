defmodule SyncMe.Availability do
  import Ecto.Query, warn: false
  require Logger
  alias SyncMe.Repo
  alias Ecto.Multi
  alias SyncMe.Partners.Partner
  alias SyncMe.Availability.AvailabilityRule
  alias SyncMe.Accounts.Scope

  def list_availability_rules(%Scope{user: user}) when not is_nil(user) do
    query =
      from r in AvailabilityRule,
        join: p in assoc(r, :partner),
        where: p.user_id == ^user.id,
        select: r

    Repo.all(query)
  end

  def list_availability_rules(%Scope{user: nil}) do
    []
  end

  def get_availability_rule!(%Scope{user: user}, id) when not is_nil(user) do
    query =
      from r in AvailabilityRule,
        join: p in assoc(r, :partner),
        where: p.user_id == ^user.id and r.id == ^id,
        select: r

    Repo.one!(query)
  end

  def create_availability_rule(%Scope{user: user}, attrs) when not is_nil(user) do
    with partner <- Repo.get_by(Partner, user_id: user.id),
         true <- !is_nil(partner) do
      attrs_with_partner = Map.put(attrs, "partner_id", partner.id)

      %AvailabilityRule{}
      |> AvailabilityRule.changeset(attrs_with_partner)
      |> Repo.insert()
    else
      false -> {:error, :partner_not_found}
    end
  end



  @doc """
  Updates an availability rule.

  It securely finds the rule by its ID, ensuring it belongs to the
  user in the scope, before applying the changes.

  Returns `{:ok, rule}` on success, `{:error, changeset}` on validation
  failure, or `{:error, :not_found_or_unauthorized}` if the rule
  doesn't exist or doesn't belong to the user.
  """
  def update_availability_rule(%Scope{} = scope, %AvailabilityRule{} = rule, attrs) do
    with :ok <- verify_rule_ownership(scope, rule),
         {:ok, changeset} <-
           rule
           |> AvailabilityRule.changeset(attrs)
           |> Ecto.Changeset.apply_action(:update) do
      Repo.update(changeset)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp verify_rule_ownership(%Scope{user: user}, rule) when not is_nil(user) do
    partner = Repo.get_by(Partner, user_id: user.id)

    if partner && partner.id == rule.partner_id do
      :ok
    else
      {:error, :not_found_or_unauthorized}
    end
  end

  defp verify_rule_ownership(%Scope{user: nil}, _rule) do
    {:error, :user_not_authenticated}
  end

  def delete_availability_rule(%Scope{} = scope, %AvailabilityRule{} = rule) do
    with :ok <- verify_rule_ownership(scope, rule) do
      Repo.delete(rule)
    else
      {:error, reason} -> {:error, reason}
    end
  end



  def save_availability_rule( %Scope{user: user} , rules) when not is_nil(user) do
    IO.inspect(rules)
    partner = Repo.get_by(Partner, user_id: user.id)
    partner_id = partner.id
    availability_rules =
      rules
      |> Enum.map( fn rule ->  Map.put( rule,  :partner_id , partner.id) end)
      |> Enum.map( fn rule ->  Map.delete(rule, :enabled) end)
      |> Enum.map( fn rule ->   AvailabilityRule.changeset(%AvailabilityRule{}, rule)  end)
    IO.inspect(availability_rules)
    queryable = from p in AvailabilityRule, where: p.partner_id == ^partner_id

    multi =
      Multi.new()
      |> Multi.delete_all(:delete_existing_rules, queryable)

    multi = Enum.reduce(availability_rules, multi, fn changeset, acc ->
                Multi.insert(acc, Ecto.Changeset.fetch_field(changeset, :day_of_week), changeset) # :some_key should be unique for each operation
            end)

    case Repo.transaction(multi) do
      {:ok, results} -> {:ok, results}
      {:error, failed_operation_key, failed_value, changes_so_far} ->
        Logger.info("The keys that failed #{inspect(failed_operation_key)} - #{inspect(changes_so_far)}")
        {:error, "Failed to insert changesets: #{inspect(failed_value)}"}
    end


  end

  alias SyncMe.Availability.AvailabilityOverride
  alias SyncMe.Accounts.Scope

  def list_availability_overrides(%Scope{user: user}) when not is_nil(user) do
    query =
      from r in AvailabilityOverride,
        join: p in assoc(r, :partner),
        where: p.user_id == ^user.id,
        select: r

    Repo.all(query)
  end

  def list_availability_overrides(%Scope{user: nil}) do
    []
  end

  def get_availability_override!(%Scope{user: user}, id) when not is_nil(user) do
    query =
      from r in AvailabilityOverride,
        join: p in assoc(r, :partner),
        where: p.user_id == ^user.id and r.id == ^id,
        select: r

    Repo.one!(query)
  end

  def create_availability_override(%Scope{user: user}, attrs) when not is_nil(user) do
    with partner <- Repo.get_by(Partner, user_id: user.id),
         true <- !is_nil(partner) do
      attrs_with_partner_id = Map.put(attrs, "partner_id", partner.id)

      %AvailabilityOverride{}
      |> AvailabilityOverride.changeset(attrs_with_partner_id)
      |> Repo.insert()
    else
      false -> {:error, :partner_not_found}
    end
  end

  def update_availability_override(
        %Scope{} = scope,
        %AvailabilityOverride{} = override,
        attrs
      ) do
    with :ok <- verify_override_ownership(scope, override),
         {:ok, changeset} <-
           override
           |> AvailabilityOverride.changeset(attrs)
           |> Ecto.Changeset.apply_action(:update) do
      Repo.update(changeset)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def delete_availability_override(
        %Scope{} = scope,
        %AvailabilityOverride{} = override
      ) do
    with :ok <- verify_override_ownership(scope, override) do
      Repo.delete(override)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def get_partner_availability(partner_id, date) do
    # returns list of available [start, end] slots
    IO.puts("Get the list of slots for #{partner_id} , #{date}")
    []
  end

  defp verify_override_ownership(%Scope{user: user}, override) when not is_nil(user) do
    partner = Repo.get_by(Partner, user_id: user.id)

    if partner && partner.id == override.partner_id do
      :ok
    else
      {:error, :not_found_or_unauthorized}
    end
  end

  defp verify_override_ownership(%Scope{user: nil}, _rule) do
    {:error, :user_not_authenticated}
  end
end
