defmodule CatFeeder.I2CTest do
  use ExUnit.Case
  alias Circuits.I2C

  test "info/0" do
    %{name: name} = I2C.info()
    assert name == :stub
  end

  test "bus_names/0" do
    list = I2C.bus_names()
    assert is_list(list)
  end

  test "detect_devices/0" do
    # assert "0 devices detected on 0 I2C buses" == I2C.detect_devices()
    assert :"do not show this result in output" == I2C.detect_devices()
  end

  test "open/1" do
    # {:ok, pid} = I2C.open("i2c-1")
    assert {:error, :bus_not_found} = I2C.open("i2c-1")
  end
end
