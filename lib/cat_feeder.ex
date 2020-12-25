defmodule CatFeeder do
  @moduledoc """
  Documentation for CatFeeder.
  """

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
end
