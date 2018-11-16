defmodule Yudhisthira do
  use Application
  @moduledoc """
  Documentation for Yudhisthira.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Yudhisthira.hello
      :world

  """
  def plug_child(plug) do
    port = case System.get_env("HTTP_PORT") do
      nil -> Application.get_env(:yudhisthira, :http_port)
      n -> (fn port ->
        {port, _} = Integer.parse(port)
        port
      end).(n)
    end
    Plug.Cowboy.child_spec(scheme: :http, plug: plug, options: [port: port])
  end

  def start(_type, _args) do
    children = [
      # Agents
      Yudhisthira.AuthenticationAgent,
      # HTTP Endpoints
      plug_child(Yudhisthira.Plugs.Http),
      # Pollers
      Yudhisthira.AuthenticationPoller
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
