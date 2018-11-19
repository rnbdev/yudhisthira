defmodule Yudhisthira.Servers.AuthenticationServer do
  use GenServer
  alias Yudhisthira.Structs.NetworkNode

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def create_new_session(incoming_node, number_map) do
    new_session_id = UUID.uuid4(:default)
    GenServer.cast(__MODULE__, {:push, new_session_id, incoming_node, number_map})
    new_session_id
  end

  def set_session_data(session_id, incoming_node, number_map) do
    # If sessions exists then set it
    if get_session_data(session_id, incoming_node) do
      GenServer.cast(__MODULE__, {:push, session_id, incoming_node, number_map})
    end
  end

  def get_session_data(session_id, incoming_node) do
    GenServer.call(__MODULE__, {:get, session_id, incoming_node})
  end

  def get_all_sessions_nodes do
    GenServer.call(__MODULE__, :getall)
  end

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call({:get, session_id, incoming_node}, _from, state) do
    {:reply,
      case node_data = Map.get(state, session_id) do
        {node, _} -> case NetworkNode.is_equal(node, incoming_node) do
          true -> node_data
          false -> nil
        end
        _ -> nil
      end,
      state
    }
  end

  @impl true
  def handle_call(:getall, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:push, session_id, node, number_map}, state) do
    {:noreply, Map.put_new(state, session_id, {
      %NetworkNode{
        ip_address: node.ip_address,
        port: node.port,
        id: node.id
      },
      number_map
    })}
  end
end