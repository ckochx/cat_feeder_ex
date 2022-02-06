defmodule CatFeeder.Camera do
  @moduledoc """
  Documentation for CatFeeder.Camera.

  Start the Picam Camera process, capture an image, write the file to the tmp dir.
  """

  @doc """
  """
  def image(name \\ "frame.jpg") do
    cam_pid = cam_pid(Picam.Camera.start_link())
    path = Path.join(System.tmp_dir!, "images")
    # default values
    Picam.set_size(1280, 720)
    File.mkdir_p(path)

    File.write!(Path.join(path, name), Picam.next_frame())
    Supervisor.stop(cam_pid)
  end

  def cam_pid({:ok, pid}), do: pid
  def cam_pid({:error, {:already_started, pid}}), do: pid
end
