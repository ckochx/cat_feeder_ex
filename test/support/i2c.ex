defmodule I2CBehaviour do
  @callback bus_names() :: list()

  @callback open(any) :: {:ok, term}

  @callback write(any, any, any) :: :ok

  @callback write_read!(any, any, any, any) :: any

  @callback detect_devices(any) :: list()
end
