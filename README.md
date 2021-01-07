# CatFeeder

Use Nerves, Stepper Motors, and a Raspberry Pi Zero to drive an automated cat feeder.

I took a lot of inspiration from http://wsmoak.net/2016/02/08/stepper-motor-elixir.html (Thanks Wendy.)

Control a stepper motor with [Elixir Circuits I2C](https://github.com/elixir-circuits/circuits_i2c#elixir-circuits---i2c)

Control a stepper motor with [Elixir Circuits GPIO](https://github.com/elixir-circuits/circuits_gpio)

Additional prose-y documentation in [Rebuild-Docs](docs/Rebuild-Docs.md)

## OTA firmware upgrades

Test the Pi is available:
`ping nerves_cat_feeder.local`

##### write out the firmware upload script (upload.sh), you only need this done once
`mix firmware.gen.script`
##### generate firmware file for the target
`MIX_TARGET=rpi0 mix firmware`
##### run the upload script
`./upload.sh nerves_cat_feeder.local ./_build/rpi0_dev/nerves/images/cat_feeder.fw`

## Targets

I wrote this code using a Raspberry Pi Zero, so all the real testing was done with that device: `MIX_TARGET=rpi0`

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi3` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/targets.html#content

## Getting Started

To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`

## Learn more

  * Official docs: https://hexdocs.pm/nerves/getting-started.html
  * Official website: https://nerves-project.org/
  * Forum: https://elixirforum.com/c/nerves-forum
  * Discussion Slack elixir-lang #nerves ([Invite](https://elixir-slackin.herokuapp.com/))
  * Source: https://github.com/nerves-project/nerves

## Additional references and resources used:
