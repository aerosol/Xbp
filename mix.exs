defmodule Xbp.Mixfile do
  use Mix.Project

  def project do
    [app: :xbp,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.7", only: :dev}]
  end
end
