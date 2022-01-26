### I2C Docs and notes

### RPi motor hat

Per Adafruit, there are two pairs of controllers for the stepper: red/yellow and green/gray (or green/brown)

The I2C ports on the hat have two marks, in my case M1/M2 and M3/M4. The center pin on each hat controller is the ground pin, marked GND.

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
