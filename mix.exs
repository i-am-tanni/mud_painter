defmodule MudPainter.MixProject do
  use Mix.Project

  def project do
    [
      app: :mud_painter,
      version: "0.9.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, "~> 0.25.0"},
      {:nimble_parsec, "~> 1.0"},
      {:jason, "~> 1.4"}
    ]
  end
end
