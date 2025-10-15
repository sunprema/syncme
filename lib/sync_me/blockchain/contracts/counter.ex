defmodule SyncMe.Blockchain.Contracts.Counter   do
  use Ethers.Contract,
  abi_file: "smart_contracts/counter.abi.json",
  default_address: Application.compile_env( :sync_me, [ :blockchain, :counter_contract_address ])
end
