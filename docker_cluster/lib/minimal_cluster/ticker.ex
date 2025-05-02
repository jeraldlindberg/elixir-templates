defmodule MinimalCluster.Ticker do
  use GenServer
  require Logger

  # No longer need @leader_name for Swarm
  @pubsub MinimalCluster.PubSub
  @topic "cluster:ticks"
  @tick_interval :timer.seconds(10)

  # Client API
  def start_link(_opts) do
    # The name registration now happens implicitly via Horde's supervisor ID
    GenServer.start_link(__MODULE__, :ok,
      name: {:via, Horde.Registry, {MinimalCluster.Registry, :ticker}}
    )
  end

  # Server Callbacks
  @impl true
  def init(_state) do
    # Subscribe to the tick topic
    Logger.info("Worker started by Horde, subscribed to #{@topic}")

    # Start the tick timer immediately - if this process runs, it IS the singleton
    schedule_tick()

    # Initial state can be empty or hold actual state
    {:ok, %{}}
  end

  # No longer need :check_leader handler

  @impl true
  def handle_info(:tick, state) do
    # This process only runs if it's the singleton managed by Horde
    Logger.info("=== SINGLETON TICK (via Horde): Broadcasting event! ===")
    Phoenix.PubSub.broadcast!(@pubsub, @topic, {:tick, DateTime.utc_now(), node()})
    schedule_tick()
    {:noreply, state}
  end

  # --- Helper Functions ---

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_interval)
  end
end
