defmodule CatFeeder.Uploader.Conn do
  @moduledoc """
  Documentation for `CatFeederUploader`.
  """

  def token do
    {:ok, token} = Goth.fetch(CatFeeder.Goth)
    token
  end

  def conn do
    GoogleApi.Drive.V3.Connection.new(token().token)
  end
end
