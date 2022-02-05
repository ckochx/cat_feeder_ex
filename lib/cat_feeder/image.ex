defmodule CatFeeder.Image do

  def capture(name \\ "frame.jpg") do
    CatFeeder.Camera.image(name)
    :timer.sleep(100)
    upload(name)
  end

  defp todays_folder do
    CatFeeder.Uploader.Folders.todays_folder()
  end

  defp upload(name) do
    folder = todays_folder()
    path = Path.join(System.tmp_dir!, ["images", name])

    CatFeeder.Uploader.Drive.create_file(path, name, folder.id)
  end
end
