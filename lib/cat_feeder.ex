defmodule CatFeeder do
  @moduledoc """
  Documentation for CatFeeder.
  """
  alias CatFeeder.Stepper

  @doc """
  Dispense the two feeder stepper motors.

  ## Example (not tested)

    CatFeeder.feed()
    :ok

  """
  def feed do
    IO.puts "Executing the feed"
    Stepper.steps(72, motor: 0, direction: :forward, style: :interleaved)
    delay()
    Stepper.steps(72, motor: 1, direction: :rev, style: :interleaved)
  end

  def feed([{s0, opt0}, {s1, opt1}]) do
    IO.puts "Executing the feed"
    Stepper.steps(s0, opt0)
    delay()
    Stepper.steps(s1, opt1)
  end

  def feed({s0, opt0}) do
    IO.puts "Executing the feed"
    Stepper.steps(s0, opt0)
  end

  defp delay do
    :cat_feeder
    |> Application.get_env(:feeding, [])
    |> Keyword.get(:delay, 2000)
    |> :timer.sleep()
  end
end
