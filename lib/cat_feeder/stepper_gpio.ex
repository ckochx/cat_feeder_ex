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

  Half Step P0 P1 P2 P3
         1  1  0  1  0
         2  0  0  1  0
         3  0  1  1  0
         4  0  1  0  0
         5  0  1  0  1
         6  0  0  0  1
         7  1  0  0  1
         8  1  0  0  0
  """

  @step_values %{
    0 => [1, 0, 1, 0],
    1 => [0, 1, 1, 0],
    2 => [0, 1, 0, 1],
    3 => [1, 0, 0, 1]
  }

  @half_step_values %{
    0 => [1, 0, 1, 0],
    1 => [0, 0, 1, 0],
    2 => [0, 1, 1, 0],
    3 => [0, 1, 0, 0],
    4 => [0, 1, 0, 1],
    5 => [0, 0, 0, 1],
    6 => [1, 0, 0, 1],
    7 => [1, 0, 0, 0]
  }

  @doc """
  Execute N steps, call step to set the correct pin values
  opts is a Keyword list and must include keys: :"0", :"1", :"2", :"3"
  where each of the required pin values is a valid? Circuits Ref ("#Ref<>") to a Pi pin.
  """
  def turn(steps, opts) do
    style = Keyword.get(opts, :style)
    Enum.each(0..(steps-1), fn step ->
      step(step, opts, style)
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
  def step(step, opts, style \\ :full)

  def step(step, opts, :half) do
    step = Integer.mod(step, 8)
    direction = Keyword.get(opts, :direction, :forward)
    step = if direction == :forward do
      step
    else
      step ^^^ 0b111
    end
    step_values = Map.get(@half_step_values, step)
    Enum.each(0..7, fn half_pin ->
      pin = Integer.mod(half_pin, 4)
      ref = Keyword.fetch!(opts, :"#{pin}")
      val = Enum.at(step_values, pin)
      GPIO.write(ref, val)
    end)
  end

  def step(step, opts, _) do
    step = Integer.mod(step, 4)
    direction = Keyword.get(opts, :direction, :forward)
    step = if direction == :forward do
      step
    else
      step ^^^ 0b11
    end
    step_values = Map.get(@step_values, step)
    Enum.each(0..3, fn pin ->
      ref = Keyword.fetch!(opts, :"#{pin}")
      val = Enum.at(step_values, pin)
      GPIO.write(ref, val)
    end)
  end
end
