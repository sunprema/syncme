defmodule SyncMe.Blockchain.Contracts.ERC1271 do
  use Ethers.Contract,
    abi_file: "smart_contracts/erc1271.abi.json",
    default_address: Application.compile_env( :sync_me, [ :blockchain, :syncme_escrow_contract_address ])

  @magic_value "0x1626ba7e"

  def valid_signature?( contract_value) do
    String.equivalent?(contract_value, @magic_value)
  end

end
