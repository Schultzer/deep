defmodule Deep.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :deep,
      version: @version,
      elixir: "~> 1.7",
      name: "Deep",
      source_url: "https://github.com/schultzer/deep",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:benchee,     "~> 1.0.1", only: :dev},
      {:deep_merge, "~> 1.0", only: :dev}
    ]
  end

  defp description do
    """
    Blazing fast and zero overhead merging of deep `map() | struct() | keyword()`.
    """
  end

  defp package do
    [
      maintainers: ["Benjamin Schultzer"],
      licenses: ["MIT"],
      links: links(),
      files: [
        "lib", "config", "mix.exs", "README*", "CHANGELOG*", "LICENSE*"
      ]
    ]
  end

  defp docs() do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: "https://github.com/schultzer/deep"
    ]
  end

  def links do
    %{
      "GitHub"    => "https://github.com/schultzer/deep",
      "Readme"    => "https://github.com/schultzer/deep/blob/v#{@version}/README.md",
      "Changelog" => "https://github.com/schultzer/deep/blob/v#{@version}/CHANGELOG.md"
    }
  end

end
