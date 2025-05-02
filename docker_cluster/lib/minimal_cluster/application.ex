defmodule MinimalCluster.Application do
  @moduledoc false
  use Application
  require Logger

  @horde_registry_name Application.get_env(
                         :libcluster,
                         :horde_registry_name,
                         MinimalCluster.DynamicRegistry
                       )
  @horde_sup_name Application.get_env(
                    :libcluster,
                    :horde_sup_name,
                    MinimalCluster.DynamicSupervisor
                  )
  @worker_singleton_id :ticker

  @impl true
  def start(_type, _args) do
    Logger.info(
      "Using Horde Registry Name: #{inspect(@horde_registry_name)}, Supervisor Name: #{inspect(@horde_sup_name)}"
    )

    children = [
      # Start the PubSub systemm
      {Phoenix.PubSub, name: MinimalCluster.PubSub},
      # Start the Horde Registryy
      {Horde.Registry, name: @horde_registry_name, keys: :unique, members: :auto},
      # Start the Dynamic Supervisor
      {Horde.DynamicSupervisor, strategy: :one_for_one, name: @horde_sup_name, members: :auto},
      # Start the supervisor based on the topologies defined in the config
      {Cluster.Supervisor, [Application.get_env(:libcluster, :topologies)]},
      # Start the listener on all nodess
      {MinimalCluster.TickListener, []}
    ]

    opts = [strategy: :one_for_one, name: MinimalCluster.Supervisor]
    sup_result = Supervisor.start_link(children, opts)

    if elem(sup_result, 0) == :ok do
      start_singleton_worker()
    end

    sup_result
  end

  defp start_singleton_worker do
    child_spec = %{
      id: @worker_singleton_id,
      start: {MinimalCluster.Ticker, :start_link, [[]]},
      restart: :permanent,
      type: :worker,
      name: {:via, Horde.Registry, {@horde_registry_name, @worker_singleton_id}}
    }

    Logger.info(
      "Attempting Horde.DynamicSupervisor.start_child with spec: #{inspect(child_spec)}"
    )

    case Horde.DynamicSupervisor.start_child(@horde_sup_name, child_spec) do
      {:ok, pid} ->
        Logger.info(
          "Successfully started singleton worker '#{@worker_singleton_id}' via Horde. PID: #{inspect(pid)}"
        )

        # Return :ok on success
        :ok

      {:ok, pid, _node} ->
        Logger.info(
          "Successfully started singleton worker '#{@worker_singleton_id}' via Horde. PID: #{inspect(pid)}"
        )

        # Return :ok on success
        :ok

      {:error, {:already_started, pid}} ->
        Logger.info(
          "Singleton worker '#{@worker_singleton_id}' already started elsewhere. PID: #{inspect(pid)}"
        )

        # Return :already_started
        :already_started

      {:error, reason} ->
        Logger.error(
          "Failed to start singleton worker '#{@worker_singleton_id}' via Horde: #{inspect(reason)}"
        )

        # Return :error on other failures
        :error
    end
  end
end
