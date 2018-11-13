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
      %{
        id: Yudhisthira.Poller,
        start: {Yudhisthira.Poller, :start_link, []}
      }
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
