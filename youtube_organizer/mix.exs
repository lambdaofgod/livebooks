defmodule YTOrg.MixProject do
  use Mix.Project

  def project do
    [
      app: :youtube_organizer,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :export]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:export, "~> 0.1.0"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.8"},
      {:goth, "~> 1.4.0"},
      {:rustler, "~> 0.27.0"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
    ]
  end
end
