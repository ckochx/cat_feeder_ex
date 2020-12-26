defmodule CatFeeder do
  @moduledoc """
  Documentation for CatFeeder.
  """
  alias CatFeeder.Stepper

  @doc """
  Dispense the feeder

  ## Examples

      iex> CatFeeder.hello()
      :world

  """
  # def feed(target) do
  #   {:ok, ref} = I2C.open("i2c-1")
  #   I2C.write(ref, 0x20, <<0x00, 0x0f>>)
  # end
  def hello do
    :world
  end

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
