defmodule CodeStats.Endpoint do
  use Phoenix.Endpoint, otp_app: :code_stats

  socket "/live_update_socket", CodeStats.LiveUpdateSocket

  plug CodeStats.RequestTime
  plug RemoteIp

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :code_stats, gzip: true,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride

  plug CodeStats.CORS

  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_code_stats_key",
    signing_salt: "UuJXllxk"

  plug CodeStats.Router
end
