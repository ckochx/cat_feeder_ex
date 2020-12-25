defmodule CatFeederTest do
  use ExUnit.Case
  import Hammox
  doctest CatFeeder

  test "greets the world" do
    assert CatFeeder.hello() == :world
  end

  test "feeds the jerks" do
    stub_with(I2CMock, CatFeeder.I2CStub)
    Application.put_env(:cat_feeder, :i2c_module, I2CMock)

    assert CatFeeder.feed() == :ok
  end
end
