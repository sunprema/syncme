defmodule SyncMe.Authenticator do

  def hash_message( message) do
    # 1. Add Ethereum Signed Message prefix and its length to the message.
    prefixed_message = "\x19Ethereum Signed Message:\n#{byte_size(message)}#{message}"
    message_binary = prefixed_message |> String.to_charlist() |> List.to_string()
    hashed_binary = ExKeccak.hash_256(message_binary)

    "0x" <> Base.encode16(hashed_binary, case: :lower)

  end

  def verify_hash(_address, message, _signature) do
    hash = hash_message(message)
    IO.inspect(hash)
    #erc6492SignatureValidatorByteCode
  end


end
