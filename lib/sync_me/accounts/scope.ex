defmodule SyncMe.Accounts.Scope do
  alias SyncMe.Accounts.User
  alias SyncMe.Partners.Partner

  defstruct user: nil, partner: nil

  @doc """
  Creates a scope for the given user.

  Returns nil if no user is given.
  """
  def for_user(%User{} = user) do
    %__MODULE__{user: user}
  end

  def for_user(nil), do: nil

  def put_partner(%__MODULE__{} = scope, %Partner{} = partner) do
    %{scope | partner: partner}
  end
end
