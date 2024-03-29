
## What am I doing?

I have a cat feeder, version 1.X (where X > 2, and X <= 10). Depending on how your count revisions, this has been working stably and reliably for a while. The first version uses a Particle Photon and servo motors. Like all hardware this version has gone through many iterations to reach a stable state. So, let's replace nearly everything!

## Goals

1) Nerves. I use elixir daily and really enjoy it, much more than the C code used in the Particle Photon. So the main goal is to use nerves to control the feeder.
  a) Raspberry Pi. Upon review, nerves mostly works with Pis. There appear to be other targets supported, but let's not complicate things. MMM π.
1) Stepper motors I don't really like the servo interface nor how they work. The ability to control them is not great, their positioning leaves something to be desired and I need a motor that can drive contonually in one direction, which the high-torque servos that I'm currently using cannot.
1) Rebuild the stand that holds the feeder hoppers. Make it nicer.

## Current limitations of the existing feeder

I have an existing cat feeder that I build and which uses a particle photon and servo motor that drives a paddle wheel in a hopper containing dry cat food. This cat feeder has gone through multiple iterations using progressivley more powerful servo motors. Currently using the [high-torque servo motors from Adafruit](https://www.adafruit.com/product/1142). This is (probably) on the high end for power generation in the 5V range, and it's still a bit under-powered to drive the paddle wheel through the cat food kibbles, especially when the hopper is full. This high-torque servo is also not a continuous rotation servo, it only rotates through about 170 degrees. The degrees of rotation are more than sufficient for the amount need to successfully dispense. But becuase the servo has to reverse direction, there is no ability to dispense only a single portion. Instead the paddle must be "tuned" to correct initial position so that and the far end of the forward rotation the minimal amount of food falls into the last dispensing section and/or on the return rotation little-to-no food is dispensed. This entire tuning operation is fraught at best.

There is also a minor performance issue with the forward and backward action of the feeder paddles, and i suspect the food would dispense with fewer issues if the paddle feeder only rotates in one direction. I.E. the paddle is always driving food into the next section and filling up the staged section.

Another factor against the particle photon controller is under that hood it uses an over the air (OTA) API in order to update the photon, it also seems like the photon needs an internet connection in order to actually work. This is not ideal. It's nice to have internet access but the control board needs to be more reliable in the event of internet or WIFI dropout.

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
  - [TB67S128FTG Stepper Motor Driver Carrier](https://www.pololu.com/product/2998)
  - [Another power supply 24V 2A](https://smile.amazon.com/gp/product/B08HQS8TS4/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)

New software:

  - [Nerves](https://hexdocs.pm/nerves/getting-started.html)
  - [Stepper motor drivers](Unecessary)
  - [Elixir Circuits - I2C](https://github.com/elixir-circuits/circuits_i2c)

Helpful references and links
  - [More stepper reference](http://wsmoak.net/2016/02/08/stepper-motor-elixir.html)
  - [RPi + Stepper](https://www.maxbotix.com/Setup-Raspberry-Pi-Zero-for-i2c-Sensor-151)
  - [RPi + Stepper Adafruit](https://learn.adafruit.com/adafruit-dc-and-stepper-motor-hat-for-raspberry-pi?view=all)
  - [I2C Technical ref](https://elixir.bootlin.com/linux/v5.10.1/source/Documentation/i2c/dev-interface.rst)
  - (https://brandonb.ca/raspberry-pi-zero-w-headless-setup-on-macos)
  - [PCA9685 Chip reference](https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf)
  - [TB67S128FTG Stepper Motor Driver Carrier](https://www.pololu.com/file/0J1697/TB67S128FTG_datasheet_en_20180612.pdf)

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

## How do I Raspberryπ?

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

After updating the SD card by removing it and inserting it into my computer (rinse and repeat), I read more! I learned you can OTA your firmware update via SSH.

Run `mix firmware.gen.script` to create an upload script. Then when you have new changes to go to the RPi, burn a new firmware and OTA it.

* `MIX_TARGET=rpi0 mix firmware.burn`

* `./upload.sh nerves_cat_feeder.local ./_build/rpi0_dev/nerves/images/cat_feeder.fw`

## Wiring Hat to Stepper

The motor controllers must be powered separately from the pi. If you send 12 or 24 V to the pi it will die and maybe even explode! The motor controller takes a 24v power supply for the steppers. A neat feature of the TB67S128FTG board is current limiting via a potentiometer. This helps ensure that you don't send more current to the steppers than they can take. Given my non-continuous usage with very long (23 + hour) breaks, I feel I could safely overclock the stepper, but when the whole system was finally tuned, there was no need to go above the recommended max current.

A neat trick I learned to determine which pair of wired form a coil in the stepper (if you do not have a diagram for your stepper) is to short two wires together. When your coil forms a loop, the resistance in the stepper will increase. If you short both pairs, then the resistance at the drive shaft becomes very high.

## Controlling the stepper

Updated documentation for the TB67S128FTG Motor Driver board lives in `CatFeeder.StepperDriver`.

Ultimately, using the TB67S128FTG board made controlling the stepper much easier. It is as simple as sending drive pulses to the motor board via several pins on the pi wored directly to the board.


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
1) _*Not exactly success*_- The motor turned, but is very weak. The new more powerful steppers arrive but they are very power hungry and my the motor hat that I purchased will not drive them correctly. In addition, the step patterns that I have are not correct. This became especially apparent with the larger motors, but is also likely a cause  of the weakness, skipping, stalling, and juttering that I am seeing in both the steppers that I am currently using.

  Also, in comparing my initial stepper code to a much closer reading of the wiring diagram for the motor hat, it appears that I was stepping out of order. Compaing to the Arduino Stepper library, the Arduino AccelStepper library and the specs for the steppers, it appears that double stepping (and possibly interleaved) are the only stepping styles. In testing, single stepping has been most unreliable. Other examples I have seen that use microstepping appear to rely more on hardware solutions (like stepper drivers.)

  Given my usage requires high torque and relatively low precision, standard double and interleaved stepping should suffice for my needs.
1) _Hardware is always super challenging_. In testing the steppers, I (somehow) created or caused a short on the pi motor bonnet, there was smoke! I assumed that I had nuked the bonnet, probably the pi, and one or more of the motors for good measure. Fortunately only one of the motor driver ports appears to have been affected. The pi still works as does one of the stepper ports.
1) "Correcting" the stepping order and using double stepping is better, especially on the original smaller stepper motor. There is still some stalling with the larger steppers, but I suspect that is due to too low current. The steppers require 2.1A while the bonnet only delivers 1.2A. More upgrades!
1) Acquire a larger 36V 4A power supply (this is too much and blew up my H-bridges)
1) Purchase H-bridges, for a "simpler" interface to the steppers.
1) There are so many stepper motor driver options.
1) While the H-bridge may be a bit dumber, it doesn't support and onboard current mitigation or "chopping", I believe it should be sufficient for my needs, and I believe the power supply _should_ help prevent any over-current situations. My use case for these steppers also features very little use. (I.E. one to three times per day for a very short duration) While the torque demands are high, the duty-cycle for these motors is very small and I'm hopeful the Pi + H-bridge configuration should work for my needs.

## Successes:

1) TB67S128FTG Stepper Motor Driver works great using a 24V 2A power supply!

  A chopper driver is a much better fit for this setup as it regulates the current and prevents the motor from drawing too much.
  It also delivers all the current the motor can handle, which is fairly significant and could easily overload the H-bridge setup. Also the H-bridge could not supply enough current to drive the larger high torque stepper.

1) The TB67S128FTG manages the individual phase signals!

  This is much better than trying to coordinate all the signals that need to get sent to each coil pair for every step.

### TODOs:

1) Cleanup the wiring.
1) Create a housing for the boards and wires.
1) Test running the pi headless via `MIX_TARGET=rpi mix firmware`
1) Try half stepping
