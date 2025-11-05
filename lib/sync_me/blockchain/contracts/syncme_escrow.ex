defmodule SyncMe.Blockchain.Contracts.SyncMeEscrow do
  use Ethers.Contract,
    abi_file: "smart_contracts/syncme.abi.json",
    default_address:
      Application.compile_env(:sync_me, [:blockchain, :syncme_escrow_contract_address])

  def contract_address() do
    "0xCc8233726f4520b74766dEa8681d2a2f4789FFFA"
  end

end
