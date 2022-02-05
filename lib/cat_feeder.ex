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
  def drive, do: drive([steps: 39])

  def drive(opts) do
    :cat_feeder
    |> Application.get_env(:hostname)
    |> get_key()
    |> drive(opts)
  end

  def drive(:kisooni = target, opts) do
    # Dispense K
    opt_k = Keyword.merge([enable_pin: 16, standby_pin: 26, jog_steps: 18, direction: :reverse, m0_pin: 25, m1_pin: 23, m2_pin: 24], opts)
    if Keyword.get(opts, :debug, false) do
      Logger.info opt_k
    end
    StepperDriver.exec(opt_k)

    async_images(target)
  end

  def drive(target, opts) do
    # Dispense H
    opt_h = Keyword.merge([enable_pin: 24, standby_pin: 23, jog_steps: 18, direction: :reverse], opts)
    if Keyword.get(opts, :debug, false) do
      Logger.info opt_h
    end
    StepperDriver.exec(opt_h)
    # Dispense Y
    delay()
    opt_y = Keyword.merge([enable_pin: 16, standby_pin: 26, jog_steps: 18], opts)
    if Keyword.get(opts, :debug, false) do
      Logger.info opt_y
    end

    StepperDriver.exec(opt_y)

    async_images(target)
  end

  defp async_images(target) do
    name = Atom.to_string(target)
    Task.async(fn -> :timer.sleep(30_000); CatFeeder.Image.capture("#{name}01.jpg") end)
    Task.async(fn -> :timer.sleep(30_000); CatFeeder.Image.capture("#{name}02.jpg") end)
    Task.async(fn -> :timer.sleep(30_000); CatFeeder.Image.capture("#{name}03.jpg") end)
  end

  defp get_key("nerves_K_feeder"), do: :kisooni
  defp get_key(_any), do: :yoki_hayangi

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
