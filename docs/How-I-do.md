
## What am I doing?


## Current limitations of the existing feeder
Given an existing cat feeder that uses a particle photon and servo motor that drives a paddle wheel in a hopper containing dry cat food. This cat feeder has gone through multiple iterations using progressivley more powerful servo motors. Currently using the [high-torque servo motors from Adafruit](https://www.adafruit.com/product/1142). This is (probably) on the high end for power generation in the 5V range, and it's still a bit under-powered to drive the paddle wheel through the cat food kibbles, especially when the hopper is full. This high-torque servo is also not a continuous rotation servo, it only rotates through about 170 degrees. The degrees of rotation are more than sufficient for the amount need to successfully dispense. But becuase the servo has to reverse direction, there is no ability to dispense only a single portion. Instead the paddle must be "tuned" to correct initial position so that and the far end of the forward rotation the minimal amount of food falls into the last dispensing section and/or on the return rotation little-to-no food is dispensed. This entire tuning operation is fraught at best.

There is also minor performance issue with the forward and backward action of the feeder paddles, and i suspect the food would dispense with fewer issues if the paddle feeder only rotates in one direction.

While the current iteration is reasonably stable, the unexpected failure of a servo has provided an opportunity to iterate again an gain a new understanding of a technology in which I have had more than passing interest for some time: [Nerves!](https://www.nerves-project.org/) I can also try out a new motor which I have been aware of for a much shorter period of time: [stepper motors](https://www.adafruit.com/product/324). Finally, this will be an opportinty to experiment with a new micro-computer board and finally jump on the Raspberry Pi wagon.

New hardware:

  - [Raspberry Pi Zero](https://www.adafruit.com/product/3708)
  - [Motor Hat (bonnet)](https://www.adafruit.com/product/4280)
  - [Stepper motors](https://www.adafruit.com/product/324)
  - [Power supply](https://smile.amazon.com/gp/product/B06Y64QLBM)
  - [Shaft Couplers](https://smile.amazon.com/gp/product/B07FXY9B8D)
  - [Brackets](https://smile.amazon.com/gp/product/B07D7P2DC3)
  - [MicroSD Card](https://smile.amazon.com/gp/product/B07R3QRGGF)

New software:

  - [Nerves](https://hexdocs.pm/nerves/getting-started.html)
  - [Stepper motor drivers](#?link=TBD)
  - [Elixir Circuits - I2C](https://github.com/elixir-circuits/circuits_i2c)

Helpful references and links
  - [More stepper reference](http://wsmoak.net/2016/02/08/stepper-motor-elixir.html)
  - [RPi + Stepper](https://www.maxbotix.com/Setup-Raspberry-Pi-Zero-for-i2c-Sensor-151)
  - [RPi + Stepper Adafruit](https://learn.adafruit.com/adafruit-dc-and-stepper-motor-hat-for-raspberry-pi?view=all)
  - [I2C Technical ref](https://elixir.bootlin.com/linux/v5.10.1/source/Documentation/i2c/dev-interface.rst)
  - (https://brandonb.ca/raspberry-pi-zero-w-headless-setup-on-macos)
## Initial setup

1) Install Nerves: `mix archive.install hex nerves_bootstrap`
1) 'new-up' a new nerves project `mix nerves.new cat_feeder`
1) `MIX_TARGET=rpi0  mix deps.get`
1) Add additional dependencies:
    - `{:circuits_i2c, "~> 0.1"}`
    - `{:mix_test_watch, "~> 1.0", only: :dev, runtime: false}`
1) Figure out how to write tests for a raspberry pi which is not yet connected.
1) Figure out how to write tests for a stepper motor.
1) Figure out how to drive a stepper motor.

## How do I RaspberryPi

Acquire a microsd card. I thought I had a few cards that came with a camera somewhere, but apparently they are all lost and gone. Buy more.

`mix firmware` -- requires `MIX_TARGET`
E.G. `MIX_TARGET=rpi0 mix firmware`

`MIX_TARGET=rpi0 mix firmware.burn` confirms the SD card that it detects before burning.

```sh
Building /Users/ck/code/cat_feeder/_build/rpi0_dev/nerves/images/cat_feeder.fw...
Use 7.5 GiB memory card found at /dev/rdisk2? [Yn] y
```

With the newly burned SD card plugged into the pi, and the pi powered up with a data-capable USB cable, the pi should respond to a ping: `ping nerves.local`

And to ssh: `ssh nerves.local`

SSH sends you to an `iex>` prompt with all your nerves code loaded.

## Wiring Hat to Stepper

Per Adafruit, there are two pairs of controllers for the stepper: red/yellow and green/gray (or green/brown)

The I2C ports on the hat have two marks, in my case M1/M2 and M3/M4. The center pin on each hat controller is the ground pin, marked GND.

The motor hat is powered separately from the pi. The hat takes a 12v power supply for the steppers.

`I2C.detect_devices` returns two addresses: 0x60 and 0x70. I'm not sure to what extent these addresses would be different on different hardware. However it appears not to matter which device address is used the steppers will turn as long as the correct pin addresses are used.

Per raspberry pi documentation:
```
Motor1 (M1, M2): ain1: 10 ain2: 9 bin1: 11 bin2: 12 pwma: 8 pwmb: 13
Motor2 (M3, M4): ain1: 4 ain2: 3 bin1: 5 bin2: 6 pwma: 2 pwmb: 7
```

## Controlling the stepper

Connecting the stepper and getting it into a state where it could turn was reasonable enough.

However understanding the low-level bit twiddling required in order to turn the stepper is proving challenging. At the first pass, there's a lot of copy-paste code that is writing a (what seems like) way too many events to the I2C bus.


