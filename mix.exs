defmodule Seedparser.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :seedparser,
      version: "0.0.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:credo, "~> 0.9.0-rc1", only: [:dev, :test], runtime: false},
      {:poison, "~> 3.0"},
      {:nostrum, git: "https://github.com/Kraigie/nostrum.git", only: [:dev, :test]},
      {:gun,
       git: "https://github.com/ninenines/gun.git",
       only: [:dev, :test],
       ref: "dd1bfe4d6f9fb277781d922aa8bbb5648b3e6756",
       override: true}
    ]
  end
end
