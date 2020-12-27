defmodule CatFeeder.I2CTest do
  @moduledoc """
  These tests aren't very valuable but they help document the I2C behavior
  """
  use ExUnit.Case
  alias Circuits.I2C

  test "info/0" do
    %{name: name} = I2C.info()
    assert name == :stub
    # With a conneted device
    # assert I2C.info() == %{name: :i2cdev}
  end

  test "bus_names/0" do
    list = I2C.bus_names()
    assert is_list(list)
    # With a conneted device
    # assert I2C.bus_names() == ["i2c-1"]
  end

  test "detect_devices/0" do
    assert :"do not show this result in output" == I2C.detect_devices()
    # With a conneted device
    # assert I2C.detect_devices() == [0x60, 0x70]
  end

  test "open/1" do
    assert {:error, :bus_not_found} = I2C.open("i2c-1")
    # With a conneted device
    # {:ok, ref} = I2C.open("i2c-1")
  end
end
