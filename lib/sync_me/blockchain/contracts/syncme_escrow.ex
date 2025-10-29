defmodule SyncMe.Blockchain.Contracts.SyncMeEscrow do
  use Ethers.Contract,
    abi_file: "smart_contracts/syncme.abi.json",
    default_address:
      Application.compile_env(:sync_me, [:blockchain, :syncme_escrow_contract_address])
end
