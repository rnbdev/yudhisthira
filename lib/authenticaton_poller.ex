defmodule Yudhisthira.AuthenticationPoller do
	use Agent

	@sleep_interval Application.get_env(:yudhisthira, :authentication_interval)

	def start_link(_) do
		Agent.start_link(fn ->
			Task.start(fn -> tick() end)
		end, name: __MODULE__)
  end

	defp tick() do
		Agent.update(__MODULE__, fn _ ->
			Task.start(fn -> 
				:timer.sleep(@sleep_interval)
				tick()
			end)
		end)
	end
end