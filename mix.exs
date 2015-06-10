defmodule CountBuffer.Mixfile do
  use Mix.Project

  def project do
    [app: :count_buffer,
     version: "0.1.0",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :pool_ring]]
  end

  defp deps do
    [{:pool_ring, "~> 0.1.0"},
     {:benchfella, "~> 0.2.0", only: :test},]
  end
end
