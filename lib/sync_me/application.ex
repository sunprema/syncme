defmodule SyncMe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SyncMeWeb.Telemetry,
      #SyncMe.Repo,
      {DNSCluster, query: Application.get_env(:sync_me, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SyncMe.PubSub},
      # Start a worker by calling: SyncMe.Worker.start_link(arg)
      # {SyncMe.Worker, arg},
      # Start to serve requests, typically the last entry
      SyncMeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SyncMe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SyncMeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
