defmodule CatFeederTest do
  use ExUnit.Case
  doctest CatFeeder

  test "greets the world" do
    assert CatFeeder.hello() == :world
  end
end
