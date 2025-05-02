defmodule MinimalCluster.TickListener do
  use GenServer
  require Logger

  @pubsub MinimalCluster.PubSub
  @topic "cluster:ticks"

  # Start this locally on each node
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(_state) do
    Logger.info("TickListener starting on node #{node()}, subscribing to '#{@topic}'")
    Phoenix.PubSub.subscribe(@pubsub, @topic)
    {:ok, %{}}
  end

  # Handle broadcast messages received via PubSub
  @impl true
  def handle_info({:tick, timestamp, producer_node}, state) do
    nodename = node()

    Logger.info(
      "--- TickConsumer on #{nodename} received TICK broadcast from #{producer_node}, timestamp: #{timestamp} ---"
    )

    # --- Add any logic here you want to run on EVERY node on tick ---
    {:noreply, state}
  end

  # Catch-all for other messages (optional but good practice)
  @impl true
  def handle_info(msg, state) do
    Logger.debug("TickConsumer received unknown message: #{inspect(msg)}")
    {:noreply, state}
  end
end
