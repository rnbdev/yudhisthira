defmodule Yudhisthira do
  import Yudhisthira.Utils.Config, only: [config: 1]
  import Yudhisthira.Utils.Ports, only: [find_free_admin_port: 0]
  require Logger
  use Application

  def plug_child(plug, port) do
    Plug.Cowboy.child_spec(scheme: :http, plug: plug, options: [port: port])
  end

  def start(_type, _args) do
    http_port = config(:http_port)
    admin_port = http_port + config(:admin_port_diff)
    Logger.info("Application starting on http://127.0.0.1:#{http_port}")
    Logger.info("Admin application running on http://127.0.0.1:#{admin_port}")
    children = [
      # GenServers
      %{
        id: Yudhisthira.Servers.PeersRepo,
        start: {Yudhisthira.Servers.PeersRepo, :start_link, []}
      },
      %{
        id: Yudhisthira.Servers.SecretsRepo,
        start: {Yudhisthira.Servers.SecretsRepo, :start_link, []}
      },
      %{
        id: Yudhisthira.Servers.AuthenticationServer,
        start: {Yudhisthira.Servers.AuthenticationServer, :start_link, []}
      },
      # HTTP apps
      plug_child(Yudhisthira.Plugs.AuthHttp, http_port),
      plug_child(Yudhisthira.Plugs.AdminHttp, admin_port)
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
