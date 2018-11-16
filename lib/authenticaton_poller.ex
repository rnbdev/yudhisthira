defmodule Yudhisthira.AuthenticationPoller do
	use Agent
	alias Yudhisthira.NodeDiscoveryAgent
	alias Yudhisthira.AuthenticationAgent
	alias Yudhisthira.AuthenticatorClient

	@sleep_interval Application.get_env(:yudhisthira, :authentication_interval)

	def start_link(_) do
		Agent.start_link(fn ->
			Task.start(fn -> tick() end)
		end, name: __MODULE__)
  end

	defp tick() do
		Enum.each(NodeDiscoveryAgent.get_nodes(), fn node ->
			case AuthenticatorClient.authenticate(node.ip_address, node.port, %{"auth": true}) do
				{:ok, authenticated} when authenticated == true -> AuthenticationAgent.add_authenticated_node(node)
				_ -> nil
			end
		end)
		# Poll every node in vicinity from the discovery agent, 
		# authenticate against them and keep then your inventory
		Agent.update(__MODULE__, fn _ ->
			Task.start(fn -> 
				:timer.sleep(@sleep_interval)
				tick()
			end)
		end)
	end
end