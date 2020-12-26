defmodule CatFeeder.StepperTest do
  use ExUnit.Case
  require Logger
  import Hammox
  alias CatFeeder.I2CStub
  alias CatFeeder.Stepper

  setup_all do
    stub_with(I2CMock, CatFeeder.I2CStub)
    Application.put_env(:cat_feeder, :i2c_module, I2CStub)
    # Set log level to debug for this test i2c_module for helpful added output
    Logger.configure(level: :debug)
    :ok
  end

  describe "turn/4" do
    test "forward" do
      # There are a lot of writes for each step. Look into this, it might not be correct or efficient
      ref = "ref"
      device_address = 99

      expect(I2CMock, :write, 80, fn ^ref, ^device_address, _ ->
        :ok
      end)

      Stepper.turn(ref, device_address, 4, motor: 0, direction: :forward, style: :single)
    end

    test "backward" do
      expect(I2CMock, :write, 80, fn "ref", 99, _ ->
        :ok
      end)

      Stepper.turn("ref", 99, 4, motor: 0, direction: :backward, style: :double)
    end
  end

  describe "steps/3" do
    test "forward" do
      assert :ok == Stepper.steps(10, motor: 0, direction: :forward)
    end

    test "backward" do
      assert :ok == Stepper.steps(3, motor: 0, direction: :backward)
    end

    test "not forward" do
      assert :ok == Stepper.steps(3, motor: 0, direction: :not_forward)
    end

    test "raises for 0 or negative steps" do
      assert_raise FunctionClauseError, fn -> Stepper.steps(0, motor: 0, direction: :forward) end
      assert_raise FunctionClauseError, fn -> Stepper.steps(-1, motor: 0, direction: :forward) end
    end
    test "raises for non-integer steps" do
      assert_raise ArgumentError, fn -> Stepper.steps(:infinity, motor: 0, direction: :forward) end
    end
  end

  describe "interleaved/0" do
    test "interleave single and double" do
      assert Stepper.interleaved == %{
        0 => [1, 1, 0, 0],
        1 => [0, 1, 0, 0],
        2 => [0, 1, 1, 0],
        3 => [0, 0, 1, 0],
        4 => [0, 0, 1, 1],
        5 => [0, 0, 0, 1],
        6 => [1, 0, 0, 1],
        7 => [1, 0, 0, 0]
      }
    end
  end
end
