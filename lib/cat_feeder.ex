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
    Stepper.steps(100, motor: 0, direction: :forward, style: :double)
    delay()
    Stepper.steps(100, motor: 1, direction: :forward, style: :double)
  end

  defp delay do
    :cat_feeder
    |> Application.get_env(:feeding, [])
    |> Keyword.get(:delay, 2000)
    |> :timer.sleep()
  end
end
