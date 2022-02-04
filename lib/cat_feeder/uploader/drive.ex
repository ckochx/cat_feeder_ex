defmodule CatFeeder.Uploader.Drive do
  @moduledoc """
  """

  alias GoogleApi.Drive.V3.Model.File, as: GFile
  alias GoogleApi.Drive.V3.Api.Files, as: GFiles

  @folder_type "application/vnd.google-apps.folder"
  # "Rainy sky":"#4986e7"
  @rainy_sky_blue "#4986e7"

  def create_folder(name, parent_id, opts \\ []) do
    {:ok, _file} = GFiles.drive_files_create(conn(), [
      body: %GFile{
        # folderColorRgb doesn't appear to work, but maybe keep trying
        folderColorRgb: @rainy_sky_blue,
        name: name,
        parents: [parent_id],
        mimeType: @folder_type,
        description: Keyword.get(opts, :description)
      }
      ])
  end

  def create_file(path, filename, parent_id, opts \\ []) do

    {mime, binary} = CatFeeder.Uploader.File.file(path)
    # Create a file from iodata
    {:ok, _file} = GFiles.drive_files_create_iodata(
      conn(),
      "multipart",
      %GFile{
        folderColorRgb: @rainy_sky_blue,
        name: filename,
        parents: [parent_id],
        mimeType: mime,
        description: Keyword.get(opts, :description)
      },
      binary
    )
  end

  def delete_by_id(id) do
    GFiles.drive_files_delete(conn(), id)
  end

  def list_files do
    GFiles.drive_files_list(conn())
  end

  defp conn do
    CatFeeder.Uploader.Conn.conn()
  end

  def folder_type, do: @folder_type
end
