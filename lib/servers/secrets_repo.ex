defmodule Yudhisthira.Servers.SecretsRepo do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def create_secret(secret_key, secret_value) do
    GenServer.call(__MODULE__, {
      :push,
      secret_key,
      secret_value
    })
  end

  def delete_secret(secret_key) do
    GenServer.call(__MODULE__, {
      :delete,
      secret_key
    })
  end

  def get_secret(secret_key) do
    GenServer.call(__MODULE__, {
      :get,
      secret_key
    })
  end

  def get_all_secrets() do
    GenServer.call(__MODULE__, {
      :getall
    })
  end

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call({:push, secret_key, secret_value}, _from, state) do
    {
      :reply,
      :ok,
      Map.merge(state, %{
        secret_key => secret_value
      })
    }
  end

  @impl true
  def handle_call({:getall}, _from, state) do
    {
      :reply,
      state,
      state
    }
  end

  @impl true
  def handle_call({:delete, secret_key}, _from, state) do
    {
      :reply,
      :ok,
      Map.delete(state, secret_key)
    }
  end

  @impl true
  def handle_call({:get, secret_key}, _from, state) do
    {
      :reply,
      Map.get(state, secret_key),
      state
    }
  end
end