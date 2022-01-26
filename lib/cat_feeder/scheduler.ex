defmodule CatFeeder.Scheduler do
  use GenServer
  require Logger

  @timezone "America/Chicago"

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Logger.info("Starting CatFeeder.Scheduler GenServer scheduler")
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    execute_scheduled_events()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    # Every Minute
    Process.send_after(self(), :work, 60 * 1000)
  end

  def current_time do
    time =
      DateTime.now(@timezone)
      |> elem(1)
      |> DateTime.to_time()

    time.hour * 100 + time.minute
  end

  def execute_scheduled_events do
    case Enum.find(schedule(), fn {time, _job} ->
           time == current_time()
         end) do
      {time, job} ->
        Logger.info("Time=#{time}; time to execute job: #{inspect(job)}")
        job.()

      _ ->
        "Nothing to do right meow."
    end
  end

  defp schedule do
    Application.get_env(:cat_feeder, :schedule, %{})
  end
end
