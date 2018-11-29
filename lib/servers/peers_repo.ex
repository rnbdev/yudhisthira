defmodule Yudhisthira.Servers.PeersRepo do
  use GenServer

  alias Yudhisthira.Structs.NetworkNode

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_peer(node) do
    GenServer.call(__MODULE__, {:push, node})
  end

  def get_peers() do
    GenServer.call(__MODULE__, {:getall})
  end

  def delete_peer(node) do
    GenServer.call(__MODULE__, {:delete, node})
  end

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call({:push, node}, _from, state) do
    {:reply, :ok, [node | state]}
  end

  @impl true
  def handle_call({:getall}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:delete, node}, _from, state) do
    {
      :reply,
      :ok,
      # TODO: not the best way... make it better
      Enum.filter(state, fn node_in_list -> not NetworkNode.is_equal(node_in_list, node) end)
    }
  end
end