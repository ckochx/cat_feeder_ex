defmodule CatFeeder.StepperGPIO do
  use Bitwise
  alias Circuits.GPIO

  @moduledoc """
  Control a stepper via GPIO pins
  The sequence of control signals for 4 control wires is as follows:
  Full Step P0 P1 P2 P3
         1  1  0  1  0
         2  0  1  1  0
         3  0  1  0  1
         4  1  0  0  1
  """

  @step_values %{
    0 => [1, 0, 1, 0],
    1 => [0, 1, 1, 0],
    2 => [0, 1, 0, 1],
    3 => [1, 0, 0, 1]
  }

  @doc """
  Manage pins and turn motor.
  Open each of the four pins, jog the motor 10 steps "backwards" and then steps + 10 forwards.
  Zero all the pin values, (set to 0, LOW).
  Close all the pin connections.
  """
  def execute(steps, pin0, pin1, pin2, pin3, opts) do
    {:ok, p0} = GPIO.open(pin0, :output)
    {:ok, p1} = GPIO.open(pin1, :output)
    {:ok, p2} = GPIO.open(pin2, :output)
    {:ok, p3} = GPIO.open(pin3, :output)
    opts = Keyword.merge(opts, "0": p0, "1": p1, "2": p2, "3": p3)

    jog_steps = 10
    # Jog backwards first
    direction = Keyword.get(opts, :direction, :forward)
    reverse = reverse(direction)
    turn(jog_steps, Keyword.merge(opts, direction: reverse))
    :timer.sleep(300)
    turn(steps + jog_steps, opts)

    :timer.sleep(100)
    off(opts)
    :timer.sleep(10)
    close(opts)
  end

  defp reverse(:forward), do: :reverse
  defp reverse(:reverse), do: :forward

  @doc """
  Execute N steps, call step to set the correct pin values
  opts is a Keyword list and must include keys: :"0", :"1", :"2", :"3"
  where each of the required pin values is a valid? Circuits Ref ("#Ref<>") to a Pi pin.
  """
  def turn(steps, opts) do
    Enum.each(0..(steps - 1), fn step ->
      step(step, opts)
      :timer.sleep(10)
    end)
  end

  @doc """
  Execute one step, setting all four pins corresponding to each coil pair.

  use bitwise XOR `^^^` to transpose the index 0 -> 3, 1 -> 2, etc
  This works because 3 (0b11) is two bits. It will also work for 7 (0b111, 3-bits), etc.

  ## Example
    ie_x> CatFeeder.StepperGPIO.step(1, ["0": "#Ref<>", ...])
    :ok

  """
  def step(step, opts) do
    step = Integer.mod(step, 4)
    direction = Keyword.get(opts, :direction, :forward)

    step =
      if direction == :forward do
        step
      else
        bxor(step, 0b11)
      end

    step_values = Map.get(@step_values, step)

    Enum.each(0..3, fn pin ->
      ref = Keyword.fetch!(opts, :"#{pin}")
      val = Enum.at(step_values, pin)
      GPIO.write(ref, val)
      :timer.sleep(5)
    end)
  end

  def off(opts) do
    Enum.each(0..3, fn pin ->
      ref = Keyword.fetch!(opts, :"#{pin}")

      GPIO.write(ref, 0)
    end)
  end

  def close(opts) do
    Enum.each(0..3, fn pin ->
      ref = Keyword.fetch!(opts, :"#{pin}")

      GPIO.close(ref)
    end)
  end
end
