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

data_dir = Path.join(System.tmp_dir!, "nerves_time_zones")
config :nerves_time_zones,
  data_dir: data_dir,
  default_time_zone: "America/Chicago"

config :cat_feeder, :schedule, %{
  0330 => &CatFeeder.drive/0,
  0611 => &CatFeeder.Uploader.Folders.purge_old_folders/0
}

config :cat_feeder, :feeding,
  delay: 3000,
  k_delay: 20_000

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

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
