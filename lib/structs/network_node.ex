defmodule Yudhisthira.Structs.NetworkNode do
  defstruct [:ip_address, :port]

  def is_equal(node1, node2) do
    node1[:ip_address] == node2[:ip_address] and 
    node1[:port] == node2[:port]
  end
end