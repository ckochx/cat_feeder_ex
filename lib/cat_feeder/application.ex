defmodule CatFeeder.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CatFeeder.Supervisor]

    children = [] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  def children(_target) do
    source = {:service_account, credentials(), [scopes: scopes]}

    [
      # Children for all targets except host
      # Hook up the GenServer Scheduler
      {CatFeeder.Scheduler, []},
      {Goth, name: CatFeeder.Goth, source: source}
    ]
  end

  def target do
    Application.get_env(:cat_feeder, :target)
  end

  defp scopes do
    [
      "https://www.googleapis.com/auth/drive",
      "https://www.googleapis.com/auth/drive.file",
      "https://www.googleapis.com/auth/drive.readonly",
      "https://www.googleapis.com/auth/drive.metadata.readonly",
      "https://www.googleapis.com/auth/drive.metadata",
      "https://www.googleapis.com/auth/drive.photos.readonly"
    ]
  end

  defp credentials do
    File.read!("config/.google_auth.json") |> Jason.decode!()
  end
end
