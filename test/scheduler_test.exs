defmodule CatFeeder.SchedulerTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  require Logger
  alias CatFeeder.Scheduler

  test "current_time" do
    time =
      DateTime.now("America/Chicago")
      |> elem(1)
      |> DateTime.to_time()

    ts = time.hour * 100 + time.minute
    assert Scheduler.current_time() == ts
  end

  test "execute_scheduled_events" do
    time =
      DateTime.now("America/Chicago")
      |> elem(1)
      |> DateTime.to_time()

    ts = time.hour * 100 + time.minute
    IO.inspect(ts, label: "timestamp")
    Application.put_env(:cat_feeder, :schedule, %{ts => fn -> Logger.info "I got called!" end})

    assert capture_log(fn -> Scheduler.execute_scheduled_events() end) =~ "[info]  I got called!"
  end
end
