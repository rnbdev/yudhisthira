defmodule Yudhisthira.Utils.Router do
  import Yudhisthira.Utils.Config, only: [config: 1]

  def admin_endpoint(symbol) do
		config(:admin_endpoint) <> config(symbol)
	end
end