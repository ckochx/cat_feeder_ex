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
    # %{name: :i2cdev}
    # assert name == :i2cdev
  end

  test "bus_names/0" do
    list = I2C.bus_names()
    assert is_list(list)
    # With a conneted device
    # assert list == ["i2c-1"]
  end

  test "detect_devices/0" do
    # With a conneted device
    # assert [0x60, 0x70] == I2C.detect_devices()
    assert :"do not show this result in output" == I2C.detect_devices()
  end

  test "open/1" do
    # With a conneted device
    # {:ok, ref} = I2C.open("i2c-1")
    # {:ok, #Reference<0.3906354015.1074397194.63195>} = I2C.open("i2c-1")
    assert {:error, :bus_not_found} = I2C.open("i2c-1")
  end
end
