defmodule SyncMe.Blockchain.Contracts.SyncMeEscrow do
  use Ethers.Contract,
    abi_file: "smart_contracts/syncme.abi.json"

  def contract_address() do
    Application.get_env(:sync_me, :blockchain) |> Keyword.get(:syncme_escrow_contract_address)
  end
end
