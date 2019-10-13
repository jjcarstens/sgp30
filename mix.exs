defmodule Sgp30.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :sgp30,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Interface with SGP30 gas sensor in Elixir",
      docs: docs(),
      package: package()
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
      {:circuits_i2c, "~> 0.3"},
      {:ex_doc, "~> 0.21", only: :docs}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: "https://github.com/jjcarstens/sgp30"
    ]
  end

  defp package do
    [
      links: %{"Github" => "https://github.com/jjcarstens/sgp30"},
      licenses: ["Apache-2.0"]
    ]
  end
end
