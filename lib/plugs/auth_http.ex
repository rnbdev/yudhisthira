defmodule Yudhisthira.Plugs.AuthHttp do
	use Plug.Router
	import Yudhisthira.Utils.Config, only: [config: 1]
	alias Yudhisthira.Controllers.AuthenticationController

	plug :match
	plug :dispatch
	
	get config(:authentication_endpoint) do
		AuthenticationController.handle_authentication_call(conn)
	end

	# Everything else goes here... 
	match _ do
		send_resp(conn, 404, "")
	end
end