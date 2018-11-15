defmodule Yudhisthira.Poller do
	use GenServer

	def start_link(_) do
		{:ok, socket} = :gen_udp.open(8769, [:binary, {:active, true}])
    GenServer.start_link(__MODULE__, %{
			socket: socket
		}, name: __MODULE__)
  end

	@impl true
	def init(stack) do
		{:ok, stack}
	end

	@impl true
	def handle_call(:pop, _from, [head | tail]) do
		{:reply, head, tail}
	end

	@impl true
	def handle_cast({:push, item}, state) do
		{:noreply, [item | state]}
	end
end