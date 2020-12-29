
## What am I doing?

I have a cat feeder, version 1.X (where X > 2, and X <= 10). Depending on how your count revisions, this has been working stably and reliably for a while. The first version uses a Particle Photon and servo motors. Like all hardware this version has gone through many iterations to reach a stable state. So, let's replace nearly everything!

## Goals

1) Nerves. I use elixir daily and really enjoy it, much more than the C code used in the Particle Photon. So the main goal is to use nerves to control the feed.
  a) Raspberry Pi. Upon review, neves mostly works with Pis. There appear to be other targets supported, but let's not complicate things. MMM pi.
1) Stepper motors I don't really like the servo interface nor how they work. The ability to control them is not great, their positioning leaves something to be desired and I need a motor that can drive contonually in one direction, which the high-torque servos that I'm currently using cannot.
1) Rebuild the stand that holds the feeder hoppers. Make it nicer.

## Current limitations of the existing feeder
Given an existing cat feeder that uses a particle photon and servo motor that drives a paddle wheel in a hopper containing dry cat food. This cat feeder has gone through multiple iterations using progressivley more powerful servo motors. Currently using the [high-torque servo motors from Adafruit](https://www.adafruit.com/product/1142). This is (probably) on the high end for power generation in the 5V range, and it's still a bit under-powered to drive the paddle wheel through the cat food kibbles, especially when the hopper is full. This high-torque servo is also not a continuous rotation servo, it only rotates through about 170 degrees. The degrees of rotation are more than sufficient for the amount need to successfully dispense. But becuase the servo has to reverse direction, there is no ability to dispense only a single portion. Instead the paddle must be "tuned" to correct initial position so that and the far end of the forward rotation the minimal amount of food falls into the last dispensing section and/or on the return rotation little-to-no food is dispensed. This entire tuning operation is fraught at best.

There is also a minor performance issue with the forward and backward action of the feeder paddles, and i suspect the food would dispense with fewer issues if the paddle feeder only rotates in one direction. I.E. the paddle is always driving food into the next section and filling up the staged section.

While the current iteration is reasonably stable, the unexpected failure of a servo has provided an opportunity to iterate again an gain a new understanding of a technology in which I have had more than passing interest for some time: [Nerves!](https://www.nerves-project.org/) I can also try out a new motor which I have been aware of for a much shorter period of time: [stepper motors](https://www.adafruit.com/product/324). Finally, this will be an opportinty to experiment with a new micro-computer board and finally jump on the Raspberry Pi wagon.

New hardware:

  - [Raspberry Pi Zero](https://www.adafruit.com/product/3708)
  - [Motor Hat (bonnet)](https://www.adafruit.com/product/4280)
  - [Stepper motors](https://www.adafruit.com/product/324)
  - [Power supply](https://smile.amazon.com/gp/product/B06Y64QLBM)
  - [Shaft Couplers](https://smile.amazon.com/gp/product/B07FXY9B8D)
  - [Brackets](https://smile.amazon.com/gp/product/B07D7P2DC3)
  - [MicroSD Card](https://smile.amazon.com/gp/product/B07R3QRGGF)
  #### More steppers
  ##### Hardware development is challenging!
  - [High Torque Steppers](https://smile.amazon.com/gp/product/B00QGBUO1C)

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
  - [PCA9685 Chip reference](https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf)
## Initial setup

1) Install Nerves: `mix archive.install hex nerves_bootstrap`
1) 'new-up' a new nerves project `mix nerves.new cat_feeder`
1) `MIX_TARGET=rpi0  mix deps.get`
1) Add additional dependencies:
    - `{:circuits_i2c, "~> 0.1"}`
    - `{:mix_test_watch, "~> 1.0", only: :dev, runtime: false}`
1) Figure out how to write tests for a raspberry pi which is not yet connected.
  Answer) Lot's of mocking and stubbing
1) Figure out how to write tests for a stepper motor.
  Answer) Lot's of mocking and stubbing
1) Figure out how to drive a stepper motor.

## How do I RaspberryPi?

Acquire a microsd card. I thought I had a few cards that came with a camera somewhere, but apparently they are all lost and gone. Buy more.

`mix firmware` -- requires `MIX_TARGET`
E.G. `MIX_TARGET=rpi0 mix firmware`

`MIX_TARGET=rpi0 mix firmware.burn` confirms the SD card that it detects before burning.

```sh
Building /Users/ck/code/cat_feeder/_build/rpi0_dev/nerves/images/cat_feeder.fw...
Use 7.5 GiB memory card found at /dev/rdisk2? [Yn] y
```

With the newly burned SD card plugged into the pi, and the pi powered up with a data-capable USB cable, the pi should respond to a ping: `ping nerves.local` (the default) or in my case `ping nerves_cat_feeder.local`

And to ssh: `ssh nerves_cat_feeder.local`

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

I attempted to document this as much as possible in `CatFeeder.Stepper`

## Issues as they arise in the build

## Or hardware is always more difficult than you expect

1) Friction- There's a lot of resistance in the hopper-motor system that makes it somewhat difficult for th stepper to properly turn the dispenser paddle.
1) Torque- Reading all the specs _remains_ fundamental. Apparently the stepper motors that I purchased have much less torque than the high-torque servo I was using. I guess I made some assumptions about how much power I would get from the stepper motors, and my assumptions were wildly incorrect.
1) Torque remedy- Investigate geared stepper motor and stepper motor gear attachments. They don't appear to sell stepper motor gear attachments. You just have to buy a new stepper motor that's geared.
1) Torque remedy- Investigate high-torque steppers. This seems a better option and I am able to find a stepper motor with comparable torque to the high-torque servos I'm replacing.
1) Despite not having quite enough torque the stepper motor is almost powerful enough. I'm optimistic about a comparable stepper motor as being functionally strong enough to drive the feeder.
1) Time- Time is always a challenging problem. By default the Raspberry Pi Zero has the incorrect time and does not automatically sync the time.
1) NTP- After investigating several avenues for setting the Pi time correctly, it appears there is already a nerves package that manages this, the aptly named `nerves-time`. Add and configure this package. (Easy)
1) Not so easy- `nerves-time` needs an internet connecition. Figure out how to get this pi access to the internet.
1) Dongle?- Looked into buying a dongle. Then I carefully reread the specs on the Pi that I purchsed. It's a Pi Zero WH (W=Wifi, H=headers). This Pi has wifi!
1) VintageNet- One of the packages loaded by Nerves is VintageNet which is used to manage network connections. Add the configuration so the Pi knows which Wifi network to use.
1) Quantum Madness- With the network connected and Time synced correctly, Quantum goes crazy and fires the scheduled jobs every few seconds. (Which is not how it's scheduled.) Let's read some issues.
1) Issue #395 and #404 - https://github.com/quantum-elixir/quantum-core/issues/395 https://github.com/quantum-elixir/quantum-core/issues/404 Quantum initializes with some default date (possibly system time) and then plays catch-up when the date syncs. This causes all the jobs that should have been scheduled to fire sequentially.
1) Replace Quantum with GenServer- Instead of trying to delay initializing quantum until some point after time is synced, don't use Quantum. While I love the quantum library for its ease of use, it appears to be a known issue that it doesn't play nicely with Nerves systems. Since we now have time synced correctly to my local timezone, just use a GenServer to check the time and NOOP or fire the job depending on the current time. I wonder if anyone has done something similar for Nerves?
1) They have!- https://github.com/supersimple/drizzle Awesome. Borrow the `Scheduler` module and adapt it to my needs.
1) A ton of runtime errors with GenServer- Mostly these were because I was starting the supervisor incorrectly. The children should be in tuple format `{CatFeeder.Scheduler, []}`, not module-only format like quantum `CatFeeder.Scheduler`. The example comments in the code show it this way, so once again it remains important to read all the words.
1) Some more config syntax errors when attempting to remove the Wifi password from committed code.
1) Tuning- While I wait for the high-torque stepper motors to get delivered, let's try to tune the stepper to dispense food when there's only a small amount of kibbles in the hopper. Style: :interleaved seems more reliable than :single or double. It's possible microstepping might also help this since more steps == more chances to overcome a stalled step.
1) Success?- Provisional success. With very little food in the dispenser, the feeder will dispense food. Hopefully torquier stepper motors will allow this setup to work much more reliably, but for now we are back to having a working cat feeder.
