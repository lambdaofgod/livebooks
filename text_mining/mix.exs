defmodule TextMining.MixProject do
  use Mix.Project

  def project do
    [
      app: :text_mining,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      config: [nx: [default_backend: EXLA.Backend]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bumblebee, "~> 0.3.0"},
      {:exla, ">= 0.0.0"},
      {:scholar, "~> 0.1.0"},
      {:nx, "~> 0.5.0", [override: true, env: :prod, hex: "nx", repo: "hexpm", optional: false]},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
    ]
  end
end
