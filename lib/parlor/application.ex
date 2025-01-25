defmodule Parlor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ParlorWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:parlor, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Parlor.PubSub},
      # Start a worker by calling: Parlor.Worker.start_link(arg)
      # {Parlor.Worker, arg},
      {Parlor.Registry, []},
      # Start to serve requests, typically the last entry
      ParlorWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Parlor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ParlorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
