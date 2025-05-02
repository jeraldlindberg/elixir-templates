defmodule MinimalCluster.MixProject do
  use Mix.Project

  def project do
    [
      app: :minimal_cluster,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        minimal_cluster: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {MinimalCluster.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_pubsub, "~> 2.1"},
      {:horde, "~> 0.8.5"},
      {:libcluster, "~> 3.3"}
    ]
  end
end
