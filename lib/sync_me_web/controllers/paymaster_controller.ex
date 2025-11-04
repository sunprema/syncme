defmodule SyncMeWeb.PaymasterController do
  use SyncMeWeb, :controller

  def proxy(conn, params) do
    paymaster_url = paymaster_url()

    case Tesla.post(paymaster_url, Jason.encode!(params), [{"Content-Type", "application/json"}]) do
      {:ok, %{status_code: 200, body: body}} ->
        json(conn, Jason.decode!(body))

      {:error, _} ->
        conn |> put_status(500) |> json(%{error: "Paymaster unavailable"})
    end
  end

  defp paymaster_url do
    Application.get_env(:sync_me, [:blockchain, :paymaster_url])
  end
end
