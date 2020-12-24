defmodule CatFeeder.I2CTest do
  use ExUnit.Case
  alias Circuits.I2C

  test "info/0" do
    %{name: name} = I2C.info()
    assert name == :stub
    # %{name: :i2cdev}
    # assert name == :i2cdev
  end

  test "bus_names/0" do
    list = I2C.bus_names()
    assert is_list(list)
    # assert list == ["i2c-1"]
  end

  test "detect_devices/0" do
    # assert "0 devices detected on 0 I2C buses" == I2C.detect_devices()
    assert {:error, :bus_not_found} == I2C.detect_devices("i2c-1")
  end

  test "open/1" do
    # {:ok, pid} = I2C.open("i2c-1")
    assert {:error, :bus_not_found} = I2C.open("i2c-1")
    # {:ok, #Reference<0.3906354015.1074397194.63195>} = I2C.open("i2c-1")
  end

  # test "write/1" do
  #   assert :ok == I2C.write(ref, 0x20, <<0x09, 0x10>>)
  # end

  # test "read/1" do
  #   assert {:ok, bin_val} == I2C.read(ref, 0x20, 11)
  # end
end
