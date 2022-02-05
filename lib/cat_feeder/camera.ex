defmodule CatFeeder.Camera do
  @moduledoc """
  Documentation for CatFeederUploader.Camera.
  """

  @doc """
  """
  def image(name \\ "frame.jpg") do
    {:ok, cam_pid} = Picam.Camera.start_link()

    path = Path.join(System.tmp_dir!, "images")
    defaults(path)
    File.write!(Path.join(path, name), Picam.next_frame)

    Supervisor.stop(cam_pid)
  end

  defp defaults(path) do
    Picam.set_size(1280, 720)
    File.mkdir_p(path)
  end
end
