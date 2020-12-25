defmodule CatFeeder.TurnyTest do
  use ExUnit.Case
  require Logger
  import Hammox
  alias CatFeeder.Turny

  setup_all do
    defmock(I2CMock, for: I2CBehaviour)
    Application.put_env(:cat_feeder, :i2c_module, I2CMock)
    # Set log level to debug for this test i2c_module for helpful added output
    Logger.configure(level: :debug)
    :ok
  end

  describe "turn_steps/3" do
    test "forward" do
      # There are a lot of writes for each step. Look into this, it might not be correct or efficient
      ref = "ref"
      device_address = 99
      expect(I2CMock, :write, 80, fn ref, device_address, _ ->
        :ok
      end)
      Turny.turn(ref, device_address, 4, motor: 0, direction: :forward, style: :single)
    end

    test "backward" do
      expect(I2CMock, :write, 80, fn "ref", 99, _ ->
        :ok
      end)
      Turny.turn("ref", 99, 4, motor: 0, direction: :backward, style: :double)
    end
  end

  describe "steps/3" do
    setup do
      stub(I2CMock, :write, fn _, _, _ ->
        :ok
      end)
      stub(I2CMock, :open, fn "i2c-1" ->
        {:ok, "Ref<>"}
      end)
      stub(I2CMock, :detect_devices, fn _ ->
        [0x60, 0x70]
      end)
      stub(I2CMock, :bus_names, fn ->
        ["i2c-1"]
      end)
      stub(I2CMock, :write_read!, fn _, _, _, _  ->
        "bit-value"
      end)
      :ok
    end

    test "forward" do
      assert :ok == Turny.steps(10, motor: 0, direction: :forward)
    end

    test "backward" do
      assert :ok == Turny.steps(3, motor: 0, direction: :backward)
    end

    test "not forward" do
      assert :ok == Turny.steps(3, motor: 0, direction: :not_forward)
    end
  end
end
