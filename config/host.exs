import Config

# Add configuration that is only needed when running on the host here.

config :goth,
  json: "config/.google_auth.json" |> File.read!()
