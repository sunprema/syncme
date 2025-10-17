defmodule SIWE do
  use Rustler, otp_app: :sync_me, crate: "siwe_ex"

   defmodule Message do
    defstruct domain: "",
              address: "",
              # or a string statement.
              statement: nil,
              uri: "",
              version: "",
              chain_id: "",
              nonce: "",
              issued_at: "",
              # or a string datetime
              expiration_time: nil,
              # or a string datetime
              not_before: nil,
              # or string
              request_id: nil,
              resources: []
  end

  # When your NIF is loaded, it will override this function.

  @doc """
    Parses a Sign In With Ethereum message string into the Message struct, or reports an error
  """
  @spec parse(String.t()) :: {:ok | :error, Message.t() | String.t()}
  def parse(_msg) do
    {:error, "NIF not loaded"}
  end

  @doc """
    Converts a Message struct to a Sign In With Ethereum message string, or reports an error
  """
  @spec to_str(Message.t()) :: {:ok | :error, String.t()}
  def to_str(_msg) do
    {:error, "NIF not loaded"}
  end

  @spec verify_sig(Message.t(), String.t()) :: boolean()
  def verify_sig(_msg, _sig), do: :erlang.nif_error(:nif_not_loaded)

  def get_new_nonce(), do: :erlang.nif_error(:nif_not_loaded)




end
