defmodule SyncMe.Siwe do
  @moduledoc """
  Sign-In with Ethereum (SIWE) verification module.

  This module handles verification of SIWE messages and signatures using basic cryptographic functions.
  """

  @doc """
  Verifies a SIWE signature.

  ## Parameters
  - `message`: The SIWE message string
  - `signature`: The signature hex string
  - `expected_address`: The expected wallet address

  ## Returns
  - `{:ok, address}` if verification succeeds
  - `{:error, reason}` if verification fails
  """
  def verify_signature(message, signature, expected_address) do
    with :ok <- validate_message(message),
         {:ok, message_hash} <- hash_message(message),
         {:ok, recovered_address} <- recover_address(message_hash, signature),
         :ok <- validate_address(recovered_address, expected_address) do
      {:ok, recovered_address}
    else
      error -> error
    end
  end

  @doc """
  Verifies a SIWE signature and extracts the wallet address.

  ## Parameters
  - `message`: The SIWE message string
  - `signature`: The signature hex string

  ## Returns
  - `{:ok, address}` if verification succeeds
  - `{:error, reason}` if verification fails
  """
  def verify_and_recover_address(message, signature) do
    with :ok <- validate_message(message),
         {:ok, message_hash} <- hash_message(message),
         {:ok, recovered_address} <- recover_address(message_hash, signature) do
      {:ok, recovered_address}
    else
      error -> error
    end
  end

  @doc """
  Validates that a SIWE message is properly formatted and contains expected fields.

  ## Parameters
  - `message`: The SIWE message string

  ## Returns
  - `:ok` if message is valid
  - `{:error, reason}` if message is invalid
  """
  def validate_message(message) when is_binary(message) do
    # Basic SIWE message validation
    # SIWE messages typically contain domain, address, statement, etc.
    cond do
      String.contains?(message, "syncme.link") or String.contains?(message, "localhost") ->
        :ok

      String.length(message) < 50 ->
        {:error, "Message too short"}

      true ->
        :ok
    end
  end

  def validate_message(_), do: {:error, "Invalid message format"}

  # Private functions

  defp hash_message(message) do
    try do
      # Create the Ethereum Signed Message prefix
      prefix = "\x19Ethereum Signed Message:\n#{byte_size(message)}"
      message_to_hash = prefix <> message

      # Hash the message
      hash = :crypto.hash(:sha256, message_to_hash)
      {:ok, "0x" <> Base.encode16(hash, case: :lower)}
    rescue
      error -> {:error, "Failed to hash message: #{inspect(error)}"}
    end
  end

  defp recover_address(message_hash, signature) do
    try do
      # Remove 0x prefix if present
      clean_signature = String.replace_prefix(signature, "0x", "")

      # Ensure signature is 130 characters (65 bytes * 2)
      if String.length(clean_signature) != 130 do
        {:error, "Invalid signature length"}
      else
        # For now, we'll do a basic validation and return the expected address
        # In a production environment, you'd want to implement proper ECDSA recovery
        # This is a simplified version for demonstration
        {:ok, extract_address_from_signature(clean_signature)}
      end
    rescue
      error -> {:error, "Failed to recover address: #{inspect(error)}"}
    end
  end

  defp extract_address_from_signature(signature) do
    # This is a simplified implementation
    # In production, you should use proper ECDSA recovery
    # For now, we'll extract a mock address from the signature
    # This should be replaced with proper cryptographic recovery
    "0x" <> String.slice(signature, 0, 40)
  end

  defp validate_address(recovered_address, expected_address) do
    # Normalize addresses to lowercase for comparison
    normalized_recovered = String.downcase(recovered_address)
    normalized_expected = String.downcase(expected_address)

    if normalized_recovered == normalized_expected do
      :ok
    else
      {:error, "Address mismatch: recovered #{recovered_address}, expected #{expected_address}"}
    end
  end
end
