import Config

# Configure Phoenix PubSub to use distributed Erlang's pg2 backend
# In a real app, you might use Redis or Postgres for PubSub persistence
config :minimal_cluster, MinimalCluster.PubSub,
  adapter: Phoenix.PubSub.PG2,
  # Keep it simple for the example
  pool_size: 1

config :horde,
  registry_name: MinimalCluster.Registry,
  supervisor_name: MinimalCluster.DynamicSupervisor,
  # Keep debug logging for Horde
  debug: true

# Import runtime config based on environment variables
import_config "runtime.exs"
