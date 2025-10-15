defmodule SyncMe.Blockchain do

alias SyncMe.Blockchain.Contracts.SyncMeEscrow

@admin Application.compile_env( :sync_me, [:blockchain, :admin])
@bob Application.compile_env( :sync_me, [:blockchain, :bob])
@alice Application.compile_env( :sync_me, [:blockchain, :alice])
@whale Application.compile_env( :sync_me, [:blockchain, :whale])
@usdc_coin Application.compile_env( :sync_me, [:blockchain, :usdc_coin])

def complete_booking(booking_id) do

  SyncMeEscrow.complete_booking(booking_id)
    |> Ethers.send_transaction( from: @admin )

end

def book_event(event_type_id) do
  naiveDateTime = NaiveDateTime.new!(2026, Enum.random(1..12), Enum.random(1..29), Enum.random(1..24), Enum.random(1..60), 0)
  datetime = DateTime.from_naive!(naiveDateTime, "America/Chicago")
  unix_epoch = DateTime.to_unix(datetime)
  SyncMeEscrow.book_event(event_type_id, unix_epoch)
    |> Ethers.send_transaction(from: @bob)
end

def create_event_type( slug, title, description, duration_minutes, fee_amount ) do
  SyncMeEscrow.create_event_type(slug, title, description, duration_minutes, fee_amount)
   |> Ethers.send_transaction(from: @alice)
end

def get_transaction_status(txhash) do
  case Ethers.get_transaction_receipt(txhash) do
    {:ok, nil} ->    {:error, nil}
    {:ok, receipt} -> {:ok, Map.get(receipt, "status")}
    _ -> {:error , "unexpected result"}
  end
end
#Ethereumex.HttpClient.post_request(Jason.encode!(%\{"method" => "hardhat_impersonateAccount", "params" => [whale], "jsonrpc" => "2.0", "id" => 1\}), [] )\

def impersonate_user(user \\ @whale) do
  payload = %{ "jsonrpc" => "2.0",
              "id" => "100",
              "method" => "hardhat_impersonateAccount",
              "params" => [user] }
  Ethereumex.HttpClient.post_request(Jason.encode!(payload), [])
end

def donate_usdc(to, value) do
  Ethers.Contracts.ERC20.transfer(to, value)
  |> Ethers.send_transaction( to: @usdc_coin, from: @whale)
end


def donate_eth_to_whale(from, value) do

  Ethers.send_transaction( %{value: value, to: @whale,}, from: from, max_fee_per_gas: 4995561)
end

end
