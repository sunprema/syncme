defmodule SyncMeWeb.WalletAuthController do
  use SyncMeWeb, :controller

  alias SyncMe.Accounts
  alias SyncMeWeb.UserAuth

  def signin(conn, %{"address" => address, "message" => message, "signature" => signature}) do
    case SyncMe.Siwe.verify_signature(message, signature, address) do
      {:ok, verified_address} ->
        case Accounts.create_or_update_wallet_user(%{wallet_address: verified_address}) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "Successfully signed in with Base!")
            |> UserAuth.log_in_user(user)

          {:error, changeset} ->
            conn
            |> put_flash(:error, "Failed to create account: #{inspect(changeset.errors)}")
            |> redirect(to: ~p"/users/log-in")
        end

      {:error, reason} ->
        conn
        |> put_flash(:error, "Signature verification failed: #{reason}")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  def signin(conn, _params) do
    conn
    |> put_flash(:error, "Missing required parameters")
    |> redirect(to: ~p"/users/log-in")
  end
end

