defmodule Yudhisthira do
  import Yudhisthira.Utils.Config, only: [config: 1]
  require Logger
  use Application

  def plug_child(plug, port) do
    Plug.Cowboy.child_spec(scheme: :http, plug: plug, options: [port: port])
  end

  def start(_type, _args) do
    Logger.info("Application starting on #{config(:http_port)}...")
    http_port = config(:http_port)
    children = [
      # GenServers
      %{
        id: Yudhisthira.Servers.SecretsRepo,
        start: {Yudhisthira.Servers.SecretsRepo, :start_link, []}
      },
      %{
        id: Yudhisthira.Servers.AuthenticationServer,
        start: {Yudhisthira.Servers.AuthenticationServer, :start_link, []}
      },
      # HTTP Endpoints
      plug_child(Yudhisthira.Plugs.Http, http_port),
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
