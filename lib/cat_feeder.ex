defmodule CatFeeder do
  @moduledoc """
  Documentation for CatFeeder.
  """
  require Logger
  alias CatFeeder.Stepper
  alias CatFeeder.StepperGPIO
  alias CatFeeder.StepperDriver

  @doc """
  Dispense N feeder stepper motors.

  ## Example (not tested)

    CatFeeder.drive()
    :ok

  """
  def drive do
    # Dispense H
    opt_h = [enable_pin: 24, standby_pin: 23, jog_steps: 18, direction: :reverse]
    StepperDriver.execute(40, opt_h)
    # Dispense Y
    delay()
    opt_y = [enable_pin: 16, standby_pin: 26, jog_steps: 18]
    StepperDriver.execute(40, opt_y)
  end

  @doc """
  Dispense the two feeder stepper motors.

  ## Example (not tested)

    CatFeeder.feed()
    :ok

  """
  def feed do
    # Dispense H
    StepperGPIO.execute(34, 17, 18, 27, 22, [])
    delay()
    # Dispense Y
    StepperGPIO.execute(34, 5, 6, 13, 19, direction: :reverse)
  end

  def feed([{s0, opt0}, {s1, opt1}]) do
    Stepper.steps(s0, opt0)
    delay()
    Stepper.steps(s1, opt1)
  end

  def feed({s0, opt0}) do
    Stepper.steps(s0, opt0)
  end

  defp delay do
    :cat_feeder
    |> Application.get_env(:feeding, [])
    |> Keyword.get(:delay, 2000)
    |> :timer.sleep()
  end
end
