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
    Plug.Cowboy.child_spec(scheme: :http, plug: plug, options: [port: 4001])
  end

  def start(_type, _args) do
    children = [
      Yudhisthira.Poller,
      plug_child(Yudhisthira.Plugs.Http)
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
