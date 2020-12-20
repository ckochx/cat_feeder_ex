
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

New software:

  - [Nerves](https://hexdocs.pm/nerves/getting-started.html)
  - [Stepper motor drivers](#?link=TBD)
  - [Elixir Circuits - I2C](https://github.com/elixir-circuits/circuits_i2c)

Helpful references and links
  - [More stepper reference](http://wsmoak.net/2016/02/08/stepper-motor-elixir.html)
  - [RPi + Stepper](https://www.maxbotix.com/Setup-Raspberry-Pi-Zero-for-i2c-Sensor-151)
  - [RPi + Stepper Adafruit](https://learn.adafruit.com/adafruit-dc-and-stepper-motor-hat-for-raspberry-pi?view=all)



