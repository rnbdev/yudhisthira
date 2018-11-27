defmodule Yudhisthira.Structs.NetworkNode do
  alias Yudhisthira.Structs.NetworkNode
  defstruct [:ip_address, :port]

  def is_equal(node1, node2) do
    node1.ip_address == node2.ip_address and 
    node1.port == node2.port
  end

  def get_ip_address(node) do
    node.ip_address
  end

  def get_port(node) do
    node.port
  end

  def create(ip_address, port) when is_bitstring(port) do
		%NetworkNode{
      ip_address: ip_address,
      port: port |> Integer.parse() |> elem(0)
    }
  end

  def create(ip_address, port) when is_integer(port) do
		%NetworkNode{
      ip_address: ip_address,
      port: port
    }
  end
end