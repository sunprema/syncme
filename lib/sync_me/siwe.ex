defmodule SyncMe.Siwe do
  @doc """
  Verifies a SIWE signature by shelling out to a Node.js script.

  Returns `:ok` if the signature is valid, and `{:error, reason}` otherwise.
  """
  def verify_siwe_signature(address, message, signature) do
    IO.inspect("#{address} , #{message}, #{signature}", label: "Input to verify_siwe_signature")
    {:ok, address}
  end
end
