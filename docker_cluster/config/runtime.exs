import Config

config :libcluster,
  topologies: [
    default: [
      strategy: Cluster.Strategy.Gossip
    ]
  ]

# Optional: Add logging for libcluster for debugging
config :logger, :console, metadata: [:libcluster_topology]
