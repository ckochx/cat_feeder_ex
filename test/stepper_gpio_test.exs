defmodule CatFeeder.StepperGPIOTest do
  use ExUnit.Case
  require Logger
  alias CatFeeder.StepperGPIO
  alias Circuits.GPIO

  doctest StepperGPIO

  setup do
    {:ok, p0_ref} = GPIO.open(16, :output)
    {:ok, p0a_ref} = GPIO.open(17, :input)
    {:ok, p1_ref} = GPIO.open(18, :output)
    {:ok, p1a_ref} = GPIO.open(19, :input)
    {:ok, p2_ref} = GPIO.open(20, :output)
    {:ok, p2a_ref} = GPIO.open(21, :input)
    {:ok, p3_ref} = GPIO.open(22, :output)
    {:ok, p3a_ref} = GPIO.open(23, :input)
    {:ok, %{
      p0_ref: p0_ref, p0a_ref: p0a_ref,
      p1_ref: p1_ref, p1a_ref: p1a_ref,
      p2_ref: p2_ref, p2a_ref: p2a_ref,
      p3_ref: p3_ref, p3a_ref: p3a_ref
    }}
  end

  describe "turn/2" do
    test "turn 4 steps", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      steps = 4
      StepperGPIO.turn(steps, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref)

      # Due to testing mock, read the adjacent pin
      # 4 steps, the last pin pattern should be for "step 3"
      assert GPIO.read(p0a_ref) == 1
      assert GPIO.read(p1a_ref) == 0
      assert GPIO.read(p2a_ref) == 0
      assert GPIO.read(p3a_ref) == 1
    end

    test "turn 8 half steps", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      steps = 8
      StepperGPIO.turn(steps, style: :half, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref)

      # Due to testing mock, read the adjacent pin
      # 8 steps, the last pin pattern should be for half "step 7"
      assert GPIO.read(p0a_ref) == 1
      assert GPIO.read(p1a_ref) == 0
      assert GPIO.read(p2a_ref) == 0
      assert GPIO.read(p3a_ref) == 0
    end

    test "turn 103 steps", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      steps = 103
      StepperGPIO.turn(steps, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref)

      # Due to testing mock, read the adjacent pin
      # 103 steps, the last pin pattern should be for "step 2"
      assert GPIO.read(p0a_ref) == 0
      assert GPIO.read(p1a_ref) == 1
      assert GPIO.read(p2a_ref) == 0
      assert GPIO.read(p3a_ref) == 1
    end

    test "turn 8 steps reverse", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      steps = 8
      StepperGPIO.turn(steps, direction: :reverse, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref)

      # Due to testing mock, read the adjacent pin
      # 8 reverse steps, the last pin pattern should be for "step 0"
      assert GPIO.read(p0a_ref) == 1
      assert GPIO.read(p1a_ref) == 0
      assert GPIO.read(p2a_ref) == 1
      assert GPIO.read(p3a_ref) == 0
    end

  end

  describe "step/2" do
    test "step 0", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      step = 0
      StepperGPIO.step(step, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref)

      # Due to testing, read the adjacent pin
      assert GPIO.read(p0a_ref) == 1
      assert GPIO.read(p1a_ref) == 0
      assert GPIO.read(p2a_ref) == 1
      assert GPIO.read(p3a_ref) == 0
    end

    test "step 0, reverse", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      step = 0
      StepperGPIO.step(step, direction: :reverse, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref)

      # Due to testing, read the adjacent pin
      assert GPIO.read(p0a_ref) == 1
      assert GPIO.read(p1a_ref) == 0
      assert GPIO.read(p2a_ref) == 0
      assert GPIO.read(p3a_ref) == 1
    end

    test "step 1", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      step = 1
      StepperGPIO.step(step, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref)

      # Due to testing, read the adjacent pin
      assert GPIO.read(p0a_ref) == 0
      assert GPIO.read(p1a_ref) == 1
      assert GPIO.read(p2a_ref) == 1
      assert GPIO.read(p3a_ref) == 0
    end

    test "step 2", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      step = 2
      StepperGPIO.step(step, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref)

      # Due to testing, read the adjacent pin
      assert GPIO.read(p0a_ref) == 0
      assert GPIO.read(p1a_ref) == 1
      assert GPIO.read(p2a_ref) == 0
      assert GPIO.read(p3a_ref) == 1
    end

    test "step 2, reverse", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      step = 2
      StepperGPIO.step(step, direction: :reverse, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref)

      # Due to testing, read the adjacent pin
      assert GPIO.read(p0a_ref) == 0
      assert GPIO.read(p1a_ref) == 1
      assert GPIO.read(p2a_ref) == 1
      assert GPIO.read(p3a_ref) == 0
    end


    test "step 3", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      step = 3
      StepperGPIO.step(step, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref)

      # Due to testing, read the adjacent pin
      assert GPIO.read(p0a_ref) == 1
      assert GPIO.read(p1a_ref) == 0
      assert GPIO.read(p2a_ref) == 0
      assert GPIO.read(p3a_ref) == 1
    end

    test "step 99", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      step = 99
      StepperGPIO.step(step, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref)

      # Due to testing, read the adjacent pin
      # 99th step, the last pin pattern should be for "step 3"
      assert GPIO.read(p0a_ref) == 1
      assert GPIO.read(p1a_ref) == 0
      assert GPIO.read(p2a_ref) == 0
      assert GPIO.read(p3a_ref) == 1
    end

    test "half step 103", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      step = 103
      StepperGPIO.step(step, ["0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref], :half)

      # Due to testing, read the adjacent pin
      # 103rd step, the last pin pattern should be for "step 7"
      assert GPIO.read(p0a_ref) == 1
      assert GPIO.read(p1a_ref) == 0
      assert GPIO.read(p2a_ref) == 0
      assert GPIO.read(p3a_ref) == 0
    end

    test "turn step 1 half-step", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      step = 1
      StepperGPIO.step(step, ["0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref], :half)

      # Due to testing mock, read the adjacent pin
      # 2nd step, the last pin pattern should be for "step 1"
      assert GPIO.read(p0a_ref) == 0
      assert GPIO.read(p1a_ref) == 0
      assert GPIO.read(p2a_ref) == 1
      assert GPIO.read(p3a_ref) == 0
    end

    test "turn step 5 half-step", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      step = 5
      StepperGPIO.step(step, ["0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref], :half)

      # Due to testing mock, read the adjacent pin
      # 6th step, the last pin pattern should be for "step 5"
      assert GPIO.read(p0a_ref) == 0
      assert GPIO.read(p1a_ref) == 0
      assert GPIO.read(p2a_ref) == 0
      assert GPIO.read(p3a_ref) == 1
    end

    test "turn step 6 half-step reverse", %{
        p0_ref: p0_ref, p0a_ref: p0a_ref,
        p1_ref: p1_ref, p1a_ref: p1a_ref,
        p2_ref: p2_ref, p2a_ref: p2a_ref,
        p3_ref: p3_ref, p3a_ref: p3a_ref
      } do
      step = 6
      StepperGPIO.step(step, [direction: :reverse, "0": p0_ref, "1": p1_ref, "2": p2_ref, "3": p3_ref], :half)

      # Due to testing mock, read the adjacent pin
      # 7th step, the last pin pattern should be for "step 1"
      assert GPIO.read(p0a_ref) == 0
      assert GPIO.read(p1a_ref) == 0
      assert GPIO.read(p2a_ref) == 1
      assert GPIO.read(p3a_ref) == 0
    end
  end
end
