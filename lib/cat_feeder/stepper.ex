defmodule CatFeeder.Stepper do
  require Logger
  use Bitwise
  alias Circuits.I2C

  @moduledoc """
  Control one or two stepper motors via a PCA9685 chip on a motor bonnet.

  This motor control was tested on an Adafruit Motor Bonnet controlling NEMA17 stepper motors.
    + [Motor Hat (bonnet)](https://www.adafruit.com/product/4280)
    + [Stepper motors](https://www.adafruit.com/product/324)

  However it _should_ work for many combinations of PCA9685 controllers and motors.
  Your mileage may vary (YMMV) and user discretion is advised.

  Module attrs are register names and address values.

  The PCA9685 Chip reference (https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf) is very helpful
  in decoding these values and their meaning.

  #### Misc Notes
  Mode1 bit 4 is SLEEP 000X0000

  Motor1 (M1, M2): ain2 9 bin1 11 ain1 10 bin2 12 pwma 8 pwmb 13
  Motor2 (M3, M4): ain2 3 bin1 5 ain1 4 bin2 6 pwma 2 pwmb 7

  Motor 1 is channels 9 and 10 with 8 held high.
  Motor 2 is channels 11 and 12 with 13 held high.
  Motor 3 is channels 3 and 4 with 2 held high.
  Motor 4 is channels 5 and 6 with 7 held high

  The diagrams in the tutorial show how the PCA9685 is connected to the TB6612's on the board
  https://learn.adafruit.com/adafruit-dc-and-stepper-motor-hat-for-raspberry-pi?view=all
  """
  @mode1 0x00
  @mode2 0x01
  @prescale 0xFE
  @all_on_l 0xFA
  @led0_on_l 0x06
  @allcall 0x01
  @outdrv 0x04
  @swrst 0x06

  @motor_pins %{
    0 => [8, 9, 10, 11, 12, 13],
    1 => [2, 3, 4, 5, 6, 7],
    :order => ["pwma", "ain2", "ain1", "bin1", "bin2", "pwmb"]
  }

  # *pin order* "ain2", "bin1", "ain1", "bin2"
  @pinput_double %{
    0 => [1, 1, 0, 0],
    1 => [0, 1, 1, 0],
    2 => [0, 0, 1, 1],
    3 => [1, 0, 0, 1]
  }

  @pinput_single %{
    0 => [0, 1, 0, 0],
    1 => [0, 0, 1, 0],
    2 => [0, 0, 0, 1],
    3 => [1, 0, 0, 0]
  }

  @doc """
  Control a stepper motor by stepping is for `steps` number of steps.
  Steps must be a non-negative integer.

  Supported `opts` (a keyword list):

    -* motor: 0 or 1 only. Turn the first or second motor.
    -* direction: :forward (default) or :backward
    -* style: :single, :double (default), or :interleaved

  In theory this code should work for a unipolar or bipolar motor. However all code was tested with
  bipolar stepper motors connected to a Raspberry Pi Zero via a Motor Bonnet

  ## Example
    # turn 25% of revolution
    ie_x> Stepper.steps(50, motor: 0, style: :double, direction: :forward)
    # turn 50% of revolution
    ie_x> Stepper.steps(100, motor: 0, style: :double, direction: :forward)
    # turn 50% of revolution interleaved
    ie_x> Stepper.steps(200, motor: 0, style: :interleaved, direction: :forward)

  In the hardwre used for testing, `I2C.detect_devices(ref)` would return two addresses. It did not
  seem to matter which address was used as the device address, so we're using the first one.
  """
  def steps(steps, opts) when steps > 0 do
    Logger.debug("Starting steps/2 with steps: #{steps} and opts: #{inspect(opts)}")
    motor = Keyword.get(opts, :motor, 0)
    [i2c_bus] = i2c().bus_names()
    {:ok, ref} = i2c().open(i2c_bus)
    [device_addr, _] = i2c().detect_devices(ref)
    init(ref, device_addr)
    prescale(ref, device_addr, 1600)
    set_pwm_ab(ref, device_addr, motor)
    turn(ref, device_addr, steps, opts)
    swrst(ref, device_addr)
  end

  @doc """
  PCA9685 Software Reset (Section 7.6 on pg 28)
  Set the chip into a known state and de-energizing the motor coils when the turning operation is complete.
  """
  def swrst(ref, device_addr) do
    Logger.debug("PCA9685 Software Reset...")
    i2c().write(ref, device_addr, <<@swrst>>)
  end

  @doc """
  `<<@mode2, @outdrv>>` external driver, see PCA9685 docs
  `<<@mode1, @allcall>>` program all PCA9685's at once
  The LED All Call I2C-bus address allows all the PCA9685s in the bus to be programmed at the same time
  (ALLCALL bit in register MODE1 must be equal to 1 (power-up default state)).
  This address is programmable through the I2C-bus and can be used during either an I2C-bus read or write sequence.
  The register address can also be programmed as a Sub Call.
  """
  def init(ref, device_addr) do
    Logger.debug("Initializing...")

    set_all_pwm(ref, device_addr, 0, 0)
    i2c().write(ref, device_addr, <<@mode2, @outdrv>>)
    i2c().write(ref, device_addr, <<@mode1, @allcall>>)
    :timer.sleep(5)
  end

  @doc """
  7.3.5
  PWM frequency PRE_SCALE
  The hardware forces a minimum value that can be loaded into the PRE_SCALE register at ‘3’.
  The PRE_SCALE register defines the frequency at which the outputs modulate.
  The prescale value is determined with the formula shown in Equation 1:(1)where the update rate is the output modulation frequency required.
  For example, for an output default frequency of 200 Hz with an oscillator clock frequency of 25 MHz:(2)
  The maximum PWM frequency is 1526 Hz if the PRE_SCALE register is set "0x03h".
  The minimum PWM frequency is 24 Hz if the PRE_SCALE register is set "0xFFh". The PRE_SCALE register can only be set when the SLEEP bit of MODE1 register is set to logic 1
  """
  def prescale(ref, device_addr, freq) do
    Logger.debug("Setting prescale to #{freq} Hz")

    # pg 14 and solve for prescale or example on pg 25
    prescaleval = trunc(Float.round(25_000_000.0 / 4096.0 / freq) - 1)
    Logger.debug("prescale value is #{prescaleval}")

    oldmode = i2c().write_read!(ref, device_addr, <<@mode1>>, 1)
    :timer.sleep(5)
    # set bit 4 (sleep) and bit 0 (ALLCALL) to allow setting prescale e.g. 1 0 0 0 1
    i2c().write(ref, device_addr, <<@mode1, 0x11>>)
    i2c().write(ref, device_addr, <<@prescale, prescaleval>>)
    # un-set sleep bit
    i2c().write(ref, device_addr, <<@mode1, 0x01>>)
    # pg 14 it takes 500 μs for the oscillator to be ready
    :timer.sleep(5)

    # put back old mode
    i2c().write(ref, device_addr, <<@mode1>> <> oldmode)
  end

  @doc """
  Activate the pins sequentially to turn the motor.

  Currently 3 stepping styles are supported: :single, :double (default), and :interleaved

  CCW (per pin diagram)
          A input 1
            channel 10
  B input 2       B input 1
    channel 12      channel 11
          A input 2
            channel 9

  There are four essential types of steps you can use with your Motor HAT.
  All four kinds will work with any unipolar or bipolar stepper motor.

  Single Steps - this is the simplest type of stepping, and uses the least power.
    It uses a single coil to 'hold' the motor in place.
  Double Steps - this is also fairly simple, except instead of a single coil, it has two coils on at once.
    For example, instead of just coil #1 on, you would have coil #1 and #2 on at once.
    This uses more power (approx 2x) but is stronger than single stepping (by maybe 25%)
  Interleaved Steps - this is a mix of Single and Double stepping, where we use single steps
    interleaved with double. It has a little more strength than single stepping,
    and about 50% more power. What's nice about this style is that it makes your
    motor appear to have 2x as many steps, for a smoother transition between steps.
  Microstepping (currently unsupported by this code) - this is where we use a mix of
    single stepping with PWM to slowly transition between steps.
    It's slower than single stepping but has much higher precision.
    We recommend 8 microstepping which multiplies the # of steps your stepper motor has by 8.
  """
  def turn(ref, device_addr, steps, opts) do
    motor = Keyword.get(opts, :motor, 0)
    direction = Keyword.get(opts, :direction, :forward)
    style = Keyword.get(opts, :style, :double)
    pin_addresses = Map.get(@motor_pins, motor)
    range = range(steps, direction)
    pinput_pattern = pin_pattern(style)
    mod_value = mod_val(style)

    Enum.each(
      range,
      fn step ->
        pin_values = Map.get(pinput_pattern, Integer.mod(step, mod_value))
        Logger.debug("#{inspect(pin_values)} -->> Pin pattern to set for step: #{step}")

        set_pins(ref, device_addr, pin_addresses, pin_values)
        :timer.sleep(10)
      end
    )

    # Stop all the pins, send 0 values
    set_pins(ref, device_addr, pin_addresses, [0, 0, 0, 0])
  end

  defp range(steps, :forward), do: 1..steps
  defp range(steps, _), do: steps..1

  defp mod_val(:interleaved), do: 8
  defp mod_val(_), do: 4

  def pin_pattern(:single), do: @pinput_single
  def pin_pattern(:interleaved), do: interleaved()
  def pin_pattern(_), do: @pinput_double

  def set_pins(ref, device_addr, [_pwma, ain2_pin, ain1_pin, bin1_pin, bin2_pin, _pwmb], [
        ain2,
        bin1,
        ain1,
        bin2
      ]) do
    set_pin(ref, device_addr, ain2_pin, ain2)
    set_pin(ref, device_addr, bin1_pin, bin1)
    set_pin(ref, device_addr, ain1_pin, ain1)
    set_pin(ref, device_addr, bin2_pin, bin2)
  end

  def set_pin(ref, device_addr, channel, 0) do
    set_pwm(ref, device_addr, channel, 0, 0x1000)
  end

  def set_pin(ref, device_addr, channel, 1) do
    set_pwm(ref, device_addr, channel, 0x1000, 0)
  end

  @doc """
  Set the PWMA and PWMB pins
  These don't need to change unless micro-stepping
  """
  def set_pwm_ab(ref, device_addr, motor) do
    [pwma_pin, _, _, _, _, pwmb_pin] = Map.get(@motor_pins, motor)
    set_pwm(ref, device_addr, pwma_pin, 0, 0x0FF0)
    set_pwm(ref, device_addr, pwmb_pin, 0, 0x0FF0)
  end

  @doc """
  See PCA9685 docs Table 7
  For each LED_n_OFF_H and LED_n_ON_H register, the 3 most significant bits (7:5) are reserved and indicated as non-writable.
  E.G. 0 0 0 * * * * *

  `LED_n full OFF` takes a (4th) bit value of: _ _ _ 1 * * * *
  `LED_n full ON` takes a (4th) bit value of: _ _ _ 0 * * * *

  _The registers for each of the 16 channels are sequential_
  _so the address can be calculated as an offset from the first one_

  I'm still struggling to understand why we're using bitwise operators here instead of sending
  the desired value. I suspect this has to do with ensuring the value changes as intended.
  0 &&& 0xff = 0 = `LED_n full ON`
  0x1000 &&& 0xff = 0
  0 >>> 8 = 0
  0x1000 >>> 8 = 16 = 1 0 0 0 0 = `LED_n full OFF`
  0x0FF0 >>> 8 = 15 = 1 1 1 1
    I'm not sure. I believe this would 0 the value of the fourth bit
    e.g. 0 0 0 0 1 1 1 1 = `LED_n full ON`
  0x0FF0 &&& 0xff = 240 = 1 1 1 1 0 0 0 0 = `LED_n full OFF`

  Use the first register address (@led0_on_l: 0x06) as the address base in order to calculate
  the offsets to each register for the current channel.

  E.G LED0_ON_L = 0x06;
  LED9, channel 9
  0x2A = 0x06 + 4 * 9 = 42 = 1 0 1 0 1 0 = LED9_ON_L
  0x2B LED9_ON_H
  0x2C LED9_OFF_L
  0X2D LED9_OFF_H

  The two LED_ON_L and LED_OFF_L registers appear to be stepped on by the _H registers.
  Leaving the references for completeness, however it appears they are not strictly necessary to turn
  the stepper in :single, :double, or :interleaved mode.
  They may be required when microstepping, which is not yet supported.
  """
  def set_pwm(ref, device_addr, channel, on, off) do
    # LED#{channel}_ON_L i2c().write(ref, device_addr, <<@led0_on_l + 4 * channel, on &&& 0xFF>>)
    # LED#{channel}_OFF_L i2c().write(ref, device_addr, <<@led0_on_l + 2 + 4 * channel, off &&& 0xFF>>)

    # LED#{channel}_ON_H
    i2c().write(ref, device_addr, <<@led0_on_l + 1 + 4 * channel, on >>> 8>>)
    # LED#{channel}_OFF_H
    i2c().write(ref, device_addr, <<@led0_on_l + 3 + 4 * channel, off >>> 8>>)
  end

  @doc """
  The PCA9685 has special registers for setting ALL channels
  (or 1/3 of them) to the same value.
  """
  def set_all_pwm(ref, device_addr, on, off) do
    i2c().write(ref, device_addr, <<@all_on_l, on &&& 0xFF>>)
    i2c().write(ref, device_addr, <<@all_on_l + 1, on >>> 8>>)
    i2c().write(ref, device_addr, <<@all_on_l + 2, off &&& 0xFF>>)
    i2c().write(ref, device_addr, <<@all_on_l + 3, off >>> 8>>)
  end

  @doc """
  Interleave the single and double pin input for :interleaved style stepping
  """
  def interleaved do
    Enum.reduce(@pinput_double, %{}, fn {k, v}, acc ->
      acc
      |> Map.put(2 * k, v)
      |> Map.put(2 * k + 1, Map.get(@pinput_single, k))
    end)
  end

  _docp = "Allow overriding the I2C module via application config."

  defp i2c do
    Application.get_env(:cat_feeder, :i2c_module, I2C)
  end
end
