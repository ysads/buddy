defmodule Buddy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BuddyWeb.Telemetry,
      Buddy.Repo,
      {DNSCluster, query: Application.get_env(:buddy, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Buddy.PubSub},
      # Start a worker by calling: Buddy.Worker.start_link(arg)
      # {Buddy.Worker, arg},
      # Start to serve requests, typically the last entry
      BuddyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Buddy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BuddyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
