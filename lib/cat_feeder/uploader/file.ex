defmodule CatFeeder.Uploader.File do
  @moduledoc """
  """

  def file(path) do
    binary = File.read!(path)
    mime = mime_type(path)
    {mime, binary}
  end

  def mime_type(path) do
    {res, _} = System.cmd("file", [path, "--mime-type"])
    if valid_read(res, path) do
      res
      |> String.split(": ")
      |> Enum.at(1)
      |> String.trim()
    else
      nil
    end
  end

  defp valid_read(result, path) do
    !Regex.match?(~r/#{path}: cannot /, result)
  end
end
