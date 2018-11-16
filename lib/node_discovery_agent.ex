defmodule Yudhisthira.NodeDiscoveryAgent do
  use Agent
  alias Yudhisthira.Structs.NetworkNode

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get_nodes do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def add_node(node) do
    Agent.update(__MODULE__, fn state -> state ++ [
      Map.merge(%NetworkNode{}, node)
    ] end)
  end

  def node_exists?(node) do
    Agent.get(__MODULE__, fn state -> 
      Enum.find(state, fn existing_node -> NetworkNode.is_equal(node, existing_node) end)
    end)
  end

  def remove_node(node) do
    Agent.update(__MODULE__, fn state -> 
      Enum.filter(state, fn existing_node ->
        not NetworkNode.is_equal(node, existing_node)
      end)
    end)
  end

  # For CLI purposes only
  def register_node(_url) do
  end
end