defmodule Yudhisthira.AuthenticationServer do
  use GenServer
  alias Yudhisthira.Structs.NetworkNode

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def create_new_session(node) do
    new_session_id = UUID.uuid4(:default)
    GenServer.cast(__MODULE__, {:push, new_session_id, node})
    new_session_id
  end

  def get_session_node(session_id, incoming_node) do
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
      case Map.get(state, session_id) do
        nil -> nil
        node -> case NetworkNode.is_equal(node, incoming_node) do
          true -> node
          false -> nil
        end
      end,
      state
    }
  end

  @impl true
  def handle_call(:getall, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:push, session_id, node}, state) do
    {:noreply, Map.put_new(state, session_id, %NetworkNode{
      ip_address: node.ip_address,
      port: node.port,
      id: node.id
    })}
  end
end