### Stepper Motor Driver

#### TB67S128FTG Stepper Motor Driver

https://www.pololu.com/product/2998

Chip data: https://toshiba.semicon-storage.com/us/semiconductor/product/motor-driver-ics/stepping-motor-driver-ics/detail.TB67S128FTG.html

### Current limiting

Per specs the TB67S128FTG uses the formula: VREF = A (amps) / 1.56

The stepper motor I'm using is rated to 2.1 amps.

VREF = 1.35 (1346 millivolts) as measured at the potentiometer screw

### Wiring Table

#### MOTOR 1 (Y)

```
VREF as measured: 1320 millivolts

TB67S128FTG   | Color   | Rπ (logical)    | Rπ (physical)

DIR           | yellow  | 20              | 38

STEP          | orange  | 21              | 40

STANDBY       | blue    | 26              | 37

ENABLE        | green   | 16              | 36

L0            | blue    | 17              | 11

L1            | green   | 27              | 13

GND           | purple  | GND             | 34
```

#### MOTOR 2 (H)

```
VREF as measured: 1350 millivolts

TB67S128FTG   | Color   | Rπ (logical)    | Rπ (physical)

DIR           | yellow  | 20              | 38

STEP          | orange  | 21              | 40

STANDBY       | blue    | 23              | 16

ENABLE        | green   | 24              | 18

L0            | blue    | 17              | 11

L1            | green   | 27              | 13

GND           | grey    | GND             | 30
```

#### MOTOR 3 (K)

```
VREF as measured: 1320 millivolts

TB67S128FTG   | Color   | Rπ (logical)    | Rπ (physical)

DIR           | yellow  | 20              | 38

STEP          | orange  | 21              | 40

STANDBY       | blue    | 26              | 37

ENABLE        | green   | 16              | 36

L0            | purple  | 17              | 11

L1            | grey    | 27              | 13

GND           | brown   | GND             | 34

MODE0         | black   | 25(gpio)        | 22

MODE1         | red     | 23(gpio)        | 16

MODE2         | white   | 24(gpio)        | 18
```

#### Note:

Pins `DIR, STEP, L0, and L1` are shared from the Rπ and the signal is sent to both boards. The TB67S128FTG board must be logically enabled by setting both STANDBY and ENABLE to HIGH (1). The non-enabled board ignores the input. You could share one of the STANDBY or ENABLE pins as well, but it seems safer to ensure they are both in the disabled state unless the board is enabled.

### 8.4. Step Resolution Select Function
MODE 0, MODE1, and MODE2 pins control the step resolution. Pin levels of MODE0, MODE1, and MODE2 can be switched during operation. The following step current depends on the electrical angle.
TB67S128FTG

MODE2 pin input     MODE1 pin input     MODE0 pin input   Function
L                   L                   L                 Full step resolution
L                   L                   H                 Half step resolution
L                   H                   L                 Quarter step resolution
H                   L                   L                 1/8 step resolution
H                   L                   H                 1/16 step resolution
H                   H                   L                 1/32 step resolution
H                   H                   H                 1/64 step resolution


Symbol

Pin No.   CLK MODE        Serial MODE       Description
49        MODE0           NC (Note1)        Excitation setting pin No.0
50        MODE1           NC (Note1)        Excitation setting pin No.1
51        MODE2           NC (Note1)        Excitation setting pin No.2
