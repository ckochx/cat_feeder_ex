defmodule CatFeeder.Stepper do
  require Logger
  use Bitwise
  alias Circuits.I2C

  # bit 4 is SLEEP 000X0000
  @mode1 0x00
  @mode2 0x01
  @prescale 0xFE

  @all_on_l 0xFA
  @all_on_h 0xFB
  @all_off_l 0xFC
  @all_off_h 0xFD

  @led0_on_l 0x06
  @led0_on_h 0x07
  @led0_off_l 0x08
  @led0_off_h 0x09

  @allcall 0x01
  @outdrv 0x04
  @swrst 0x06

  # These seem to be some of the 16 channels on the PCA9685
  # I think the diagrams in the tutorial show how the PCA9685 is connected to the TB6612's on the board
  # https://learn.adafruit.com/adafruit-dc-and-stepper-motor-hat-for-raspberry-pi?view=all
  # Motor1 (M1, M2): ain2 9 bin1 11 ain1 10 bin2 12 pwma 8 pwmb 13
  # Motor2 (M3, M4): ain2 3 bin1 5 ain1 4 bin2 6 pwma 2 pwmb 7

  # Motor 1 is channels 9 and 10 with 8 held high.
  # Motor 2 is channels 11 and 12 with 13 held high.
  # Motor 3 is channels 3 and 4 with 2 held high.
  # Motor 4 is channels 5 and 6 with 7 held high

  @motor_pins %{
    0 => [8, 9, 10, 11, 12, 13],
    1 => [2, 3, 4, 5, 6, 7],
    :order => [:pwma, :ain2, :ain1, :bin1, :bin2, :pwmb]
  }
  # [ain2, bin1, ain1, bin2]
  @pinput_double %{
    0 => [1, 1, 0, 0],
    1 => [0, 1, 1, 0],
    2 => [0, 0, 1, 1],
    3 => [1, 0, 0, 1]
  }

  @pinput_single %{
    0 => [1, 0, 0, 0],
    1 => [0, 1, 0, 0],
    2 => [0, 0, 1, 0],
    3 => [0, 0, 0, 1]
  }

  def steps(steps, opts) do
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

  # PCA9685 Software Reset (Section 7.6 on pg 28)
  # Set the chip into a known state
  def swrst(ref, device_addr) do
    Logger.debug("PCA9685 Software Reset...")
    i2c().write(ref, device_addr, <<@swrst>>)
  end

  def init(ref, device_addr) do
    Logger.debug("Initializing...")

    set_all_pwm(ref, device_addr, 0, 0)

    # external driver, see docs
    i2c().write(ref, device_addr, <<@mode2, @outdrv>>)
    # program all PCA9685's at once
    i2c().write(ref, device_addr, <<@mode1, @allcall>>)
    :timer.sleep(5)
  end

  @doc "set pwm to freq Hz (1600)"
  def prescale(ref, device_addr, freq) do
    Logger.debug("Setting prescale to #{freq} Hz")

    # pg 14 and solve for prescale or example on pg 25
    prescaleval = trunc(Float.round(25_000_000.0 / 4096.0 / freq) - 1)
    Logger.debug("prescale value is #{prescaleval}")

    oldmode = i2c().write_read!(ref, device_addr, <<@mode1>>, 1)
    :timer.sleep(5)
    # set bit 4 (sleep) to allow setting prescale
    i2c().write(ref, device_addr, <<@mode1, 0x11>>)
    i2c().write(ref, device_addr, <<@prescale, prescaleval>>)
    # un-set sleep bit
    i2c().write(ref, device_addr, <<@mode1, 0x01>>)
    # pg 14 it takes 500 us for the oscillator to be ready
    :timer.sleep(5)

    # put back old mode
    i2c().write(ref, device_addr, <<@mode1>> <> oldmode)
  end

  @doc """

  Additional turning style info
  Turn style
  if style == SINGLE:
                 self._steps = _SINGLE_STEPS
             elif style == DOUBLE:
                 self._steps = _DOUBLE_STEPS
             elif style == INTERLEAVE:
                 self._steps = _INTERLEAVE_STEPS
             else:
                 raise ValueError("Unsupported step style.")
  Single or double (torque) step pattern
  _SINGLE_STEPS = bytes([0b0010, 0b0100, 0b0001, 0b1000])

  _DOUBLE_STEPS = bytes([0b1010, 0b0110, 0b0101, 0b1001])

  _INTERLEAVE_STEPS = bytes(
    [0b1010, 0b0010, 0b0110, 0b0100, 0b0101, 0b0001, 0b1001, 0b1000]
  )

  """
  def turn(ref, device_addr, steps, opts) do
    motor = Keyword.get(opts, :motor, 0)
    direction = Keyword.get(opts, :direction, :forward)
    style = Keyword.get(opts, :style, :double)
    pin_addresses = Map.get(@motor_pins, motor)

    range =
      if direction == :forward do
        1..steps
      else
        steps..1
      end
    pinput_pattern = if style == :single do
      @pinput_single
    else
      @pinput_double
    end

    Enum.each(
      range,
      fn step ->
        Logger.debug("turning step #{step}")
        pin_values = Map.get(pinput_pattern, Integer.mod(step, 4))
        Logger.debug("#{inspect(pin_values)} -->> Pin pattern to set for step: #{step}")

        set_pins(ref, device_addr, pin_addresses, pin_values)
        :timer.sleep(10)
      end
    )

    # Stop all the pins
    zeroes = [0, 0, 0, 0]
    set_pins(ref, device_addr, pin_addresses, zeroes)
  end

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

  # These don't need to change unless you are micro-stepping
  def set_pwm_ab(ref, device_addr, motor) do
    [pwma_pin, _, _, _, _, pwmb_pin] = Map.get(@motor_pins, motor)
    set_pwm(ref, device_addr, pwma_pin, 0, 0x0FF0)
    set_pwm(ref, device_addr, pwmb_pin, 0, 0x0FF0)
  end

  @doc """
  TODO: Verify this sentence about the channels and what value they're getting set to.
  Are all these writes strictly necessary?

  The registers for each of the 16 channels are sequential
  so the address can be calculated as an offset from the first one
  """
  def set_pwm(ref, device_addr, channel, on, off) do
    i2c().write(ref, device_addr, <<@led0_on_l + 4 * channel, on &&& 0xFF>>)
    i2c().write(ref, device_addr, <<@led0_on_h + 4 * channel, on >>> 8>>)
    i2c().write(ref, device_addr, <<@led0_off_l + 4 * channel, off &&& 0xFF>>)
    i2c().write(ref, device_addr, <<@led0_off_h + 4 * channel, off >>> 8>>)
  end

  # The PCA9685 has special registers for setting ALL channels
  # (or 1/3 of them) to the same value.
  def set_all_pwm(ref, device_addr, on, off) do
    i2c().write(ref, device_addr, <<@all_on_l, on &&& 0xFF>>)
    i2c().write(ref, device_addr, <<@all_on_h, on >>> 8>>)
    i2c().write(ref, device_addr, <<@all_off_l, off &&& 0xFF>>)
    i2c().write(ref, device_addr, <<@all_off_h, off >>> 8>>)
  end

  defp i2c do
    Application.get_env(:cat_feeder, :i2c_module, I2C)
  end
end
