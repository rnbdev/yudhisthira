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
  def start(_type, _args) do
    children = [
      Yudhisthira.Poller,
      Plug.Cowboy.child_spec(scheme: :http, plug: Yudhisthira.Http, options: [port: 4001])
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
