defmodule CatFeeder.MixProject do
  use Mix.Project

  @app :cat_feeder
  @version "0.1.0"
  @all_targets [:rpi0]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {CatFeeder.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.7", runtime: false},
      {:shoehorn, "~> 0.7.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.3", targets: @all_targets},
      {:nerves_pack, "~> 0.4.0", targets: @all_targets},
      {:nerves_time, "~> 0.4.2"},
      # We need a TZDB to work with local timezones
      {:nerves_time_zones, "~> 0.1.2"},

      # Dependencies for specific targets
      # Since we're only building on a Pi Zero, lose the other targets
      {:nerves_system_rpi0, "~> 1.13", runtime: false, targets: :rpi0},
      {:nerves_system_rpi, "~> 1.13", runtime: false, targets: :rpi},

      # Communicate with RaspberryPi via I2C and GPIO circuits
      {:circuits_i2c, "~> 0.1"},
      {:circuits_gpio, "~> 0.4"},

      # GoogleDrive packages
      {:goth, "~> 1.3-rc"},
      {:hackney, ">= 1.17.0"},
      {:google_api_drive, ">= 0.22.0"},
      # Camera Control
      {:picam, "~> 0.4.0"},

      # Dev and Test Deps
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:hammox, "~> 0.3", only: :test}
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end

  def hostname do
    System.get_env("HOSTNAME", "nerves_DEFAULT_feeder")
  end
end
