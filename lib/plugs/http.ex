defmodule Yudhisthira.Plugs.Http do
	use Plug.Router
	alias Yudhisthira.Controllers.AuthenticationController

	plug :match
	plug :dispatch
	
	get Application.get_env(:yudhisthira, :authentication_endpoint) do
		AuthenticationController.handle_authentication_call(conn)
	end

	# Everything else goes here... really
	match _ do
		send_resp(conn, 400, "")
	end
end