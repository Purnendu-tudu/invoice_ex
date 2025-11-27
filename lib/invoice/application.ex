defmodule Invoice.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      InvoiceWeb.Telemetry,
      # Invoice.Repo,
      {DNSCluster, query: Application.get_env(:invoice, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Invoice.PubSub},
      # Start a worker by calling: Invoice.Worker.start_link(arg)
      # {Invoice.Worker, arg},
      # Start to serve requests, typically the last entry
      InvoiceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Invoice.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InvoiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
