# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config
require Logger

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

config :cat_feeder, target: Mix.target()

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :cat_feeder, CatFeeder.Scheduler,
  timezone: "America/Chicago",
  jobs: [
    feed_0330: [
      schedule: "30 03 * * *",
      task: {CatFeeder, :feed, []}
    ]
  ]

config :cat_feeder, :feeding, delay: 2000

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1608433580"

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

if Mix.target() == :host or Mix.target() == :"" do
  import_config "host.exs"
else
  import_config "target.exs"
end

# Test env config
if Mix.env() == :test do
  config :cat_feeder, :feeding, delay: 200

  config :logger,
    backends: [:console],
    level: :info
end

# Dev env config
if Mix.env() == :dev do
  config :logger,
    backends: [:console],
    level: :debug

  # Fire every minute for testing
  config :cat_feeder, CatFeeder.Scheduler,
    jobs: [
      feed: [
        schedule: "*/1 * * * *",
        task: {CatFeeder, :feed, []}
      ]
    ]
end
