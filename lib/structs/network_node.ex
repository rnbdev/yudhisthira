defmodule Yudhisthira.Structs.NetworkNode do
  alias Yudhisthira.Structs.NetworkNode
  defstruct [:ip_address, :port, :id]

  def is_equal(node1, node2) do
    node1.ip_address == node2.ip_address and 
    node1.port == node2.port
  end

  def create(ip_address, port) do
		%NetworkNode{
      ip_address: ip_address,
      port: case is_bitstring(port) do
        true -> port |> Integer.parse() |> Kernel.elem(0)
        false -> port
      end
    }
  end
end