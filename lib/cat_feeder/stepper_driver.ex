defmodule CatFeeder.StepperDriver do
  use Bitwise
  require Logger
  alias Circuits.GPIO

  @moduledoc """
  Control a stepper connected through a stepper motor driver carrier, in this case a TB67S128FTG board
  CW = 1 CCW = 0
  SPR (steps per revolution) 200
  """

  @dir_pin 20
  @step_pin 21
  @l0_pin 17
  @l1_pin 27

  @doc """
  Manage pins and turn motor.
  Open each of the pins, jog the motor N steps "backward" and then steps + N forward.
  Zero all the pin values, (set to 0, LOW).
  Close all the pin connections.
  """
  def execute(steps, opts \\ []) do
    refs = [dir_ref, step_ref], ena_ref, stby_ref, l0_ref, l1_ref] = open(opts)

    enable(ena_ref, stby_ref, l0_ref, l1_ref)

    dir = Keyword.get(opts, :direction, :forward)
    reverse = reverse(dir)
    # Set direction inverse to opts dir
    GPIO.write(dir_ref, dir_val(reverse))
    # Jog N steps backwards first
    jog_steps = Keyword.get(opts, :jog_steps, 0)
    turn(jog_steps, step_ref, l0_ref, l1_ref)
    :timer.sleep(500)
    # Set direction pin value
    GPIO.write(dir_ref, dir_val(dir))
    turn(steps + jog_steps, step_ref, l0_ref, l1_ref)

    :timer.sleep(100)
    close(refs)
  end

  defp open(opts) do
    {:ok, dir_ref} =
      opts
      |> Keyword.get(:dir_pin, @dir_pin)
      |> GPIO.open(:output)
    {:ok, step_ref} =
       opts
      |> Keyword.get(:step_pin, @step_pin)
      |> GPIO.open(:output)
    {:ok, ena_ref} =
      opts
      |> Keyword.fetch!(:enable_pin)
      |> GPIO.open(:output)
    {:ok, stby_ref} =
      opts
      |> Keyword.fetch!(:standby_pin)
      |> GPIO.open(:output)

    {:ok, l0_ref} =
       opts
      |> Keyword.get(:l0_pin, @l0_pin)
      |> GPIO.open(:output)

    {:ok, l1_ref} =
      opts
      |> Keyword.get(:l1_pin, @l1_pin)
      |> GPIO.open(:output)

    [dir_ref, step_ref], ena_ref, stby_ref, l0_ref, l1_ref]
  end

  defp enable(ena_ref, stby_ref, l0_ref, l1_ref) do
    # write enable and standby to HIGH to enable the driver board
    GPIO.write(ena_ref, 1)
    GPIO.write(stby_ref, 1)
    # write the error pins to HIGH to enable error detaction
    GPIO.write(l0_ref, 1)
    GPIO.write(l1_ref, 1)
  end

  defp reverse(:forward), do: :reverse
  defp reverse(:reverse), do: :forward

  defp dir_val(:forward), do: 1
  defp dir_val(:reverse), do: 0

  @doc """
  Execute N steps, write the pin to high (1), then low (0) with a small delay between each command.
  This approach is relatively low resolution and relies on the timing in the microcontroller (Rπ).

  The driver board can work with a PWM signal for much finer resoltion and many more steps per cycle.

  For my use this resolution is sufficient.
  """
  def turn(0, _, _, _), do: :ok

  def turn(steps, step_ref, l0, l1) do
    Enum.each((1..steps), fn _step ->
      GPIO.write(step_ref, 1)
      :timer.sleep(10)
      GPIO.write(step_ref, 0)
      :timer.sleep(10)
      detect_err(l0, l1)
    end)
  end

  @doc """
    read the l0 and l1 pin values.
    1,1 Normal operation
    1,0 Detected motor load open (OPD)
    0,1 Detected over current (ISD)
    0,0 Detected thermal shutdown (TSD)
  """
  def detect_err(l0_ref, l1_ref) do
    v0 = GPIO.read(l0_ref)
    v1 = GPIO.read(l1_ref)
    log_error(v0, v1)
  end

  defp log_error(1, 1), do: :ok

  defp log_error(v0, v1) do
    Logger.warn("Error detected, pin 0 value: #{v0}")
    Logger.warn("Error detected, pin 1 value: #{v1}")
  end

  def close([dir_ref, step_ref, ena_ref, stby_ref, l0_ref, l1_ref]) do
    # write enable and standby to LOW to disable the board
    GPIO.write(ena_ref, 0)
    GPIO.write(stby_ref, 0)

    # Close all the pin connections
    GPIO.close(l0_ref)
    GPIO.close(l1_ref)
    GPIO.close(ena_ref)
    GPIO.close(stby_ref)
    GPIO.close(dir_ref)
    GPIO.close(step_ref)
  end
end
