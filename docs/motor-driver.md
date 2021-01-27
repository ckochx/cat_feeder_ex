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

#### Note:

Pins `DIR, STEP, L0, and L1` are shared from the Rπ and the signal is sent to both boards. The TB67S128FTG board must be logically enabled by setting both STANDBY and ENABLE to HIGH (1). The non-enabled board ignores the input. You could share one of the STANDBY or ENABLE pins as well, but it seems safer to ensure they are both in the disabled state unless the board is enabled.
