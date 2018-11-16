defmodule Yudhisthira.AuthenticationPoller do
	use Agent

	@sleep_interval Application.get_env(:yudhisthira, :authentication_interval)

	def start_link(_) do
		Agent.start_link(fn ->
			Task.start(fn -> tick() end)
		end, name: __MODULE__)
  end

	defp tick() do
		# Poll every node in vicinity from the discovery agent, 
		# authenticate against them and keep then your inventory
		Agent.update(__MODULE__, fn ->
			Task.start(fn -> 
				:timer.sleep(@sleep_interval)
				tick()
			end)
		end)
	end
end