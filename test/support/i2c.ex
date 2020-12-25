defmodule I2CBehaviour do
  @callback bus_names() :: list()

  @callback open(any) :: {:ok, term}

  @callback write(any, any, any) :: :ok

  @callback write_read!(any, any, any, any) :: any

  @callback detect_devices(any) :: list()
end

defmodule CatFeeder.I2CStub do
  @behaviour I2CBehaviour

  @impl I2CBehaviour
  def open(_), do: {:ok, "#Ref<>"}
  @impl I2CBehaviour
  def detect_devices(_), do: detect_devices()
  def detect_devices, do: [0x60, 0x70]
  @impl I2CBehaviour
  def bus_names, do: ["i2c-1"]
  @impl I2CBehaviour
  def write(_, _, _), do: :ok
  @impl I2CBehaviour
  def write_read!(_, _, _, _), do: "bin-value"
end
