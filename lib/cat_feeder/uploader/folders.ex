defmodule CatFeeder.Uploader.Folders do
  @moduledoc """
  """
  alias CatFeeder.Uploader.Drive
  alias GoogleApi.Drive.V3.Model.File, as: GFile

  @tz "America/Chicago"
  @day_in_seconds 60*60*24

  def todays_folder(tz \\ @tz) do
    {:ok, time} = DateTime.now(tz)
    name = Calendar.strftime(time, "%Y%m%d")
    {:ok, files} = Drive.list_files
    case find_folder(files.files, name) do
      %GFile{} = file -> file
      _ ->
        {:ok, %GFile{} = file} = create_folder(name, uploads_folder_id(), description: "Today's folder created by the CatFeeder.Uploader app")
        file
      end
  end

  def uploads_folder_id do
    {:ok, files} = Drive.list_files
    uploads = Enum.find(files.files, &(&1.name) == "uploads")
    uploads.id
  end

  def purge_old_folder(days \\ 30) do
    # Purge at 30, 31, and 32 days (31 and 32 TBD)
    seconds = @day_in_seconds * -1 * days
    time = DateTime.add(DateTime.utc_now, seconds, :second)

    name = Calendar.strftime(time, "%Y%m%d")
    {:ok, files} = Drive.list_files
    find_and_purge(files.files, name)
  end

  defp find_and_purge(files, name) do
    case find_folder(files, name) do
      %GFile{id: id} ->
        Drive.delete_by_id(id)
      _ -> :noop
    end
  end

  defp find_folder(files, name) do
    Enum.find(files, &
      &1.name == name and &1.mimeType == Drive.folder_type()
    )
  end
end
