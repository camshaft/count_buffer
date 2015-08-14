defmodule CountBuffer.Mixfile do
  use Mix.Project

  def project do
    [app: :count_buffer,
     version: "0.1.4",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "buffer a large set of counters and flush periodically",
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger, :pool_ring]]
  end

  defp deps do
    [{:pool_ring, "~> 0.1.0"},
     {:benchfella, "~> 0.2.0", only: :test},]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*"],
     contributors: ["Cameron Bytheway"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/camshaft/count_buffer"}]
  end
end
