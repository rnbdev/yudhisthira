defmodule Yudhisthira.Plugs.Http do
	use Plug.Router
	import Yudhisthira.Utils.Config, only: [config: 1]
	alias Yudhisthira.Controllers.AuthenticationController
	alias Yudhisthira.Controllers.AdminController

	plug :match
	plug :dispatch
	
	get config(:authentication_endpoint) do
		AuthenticationController.handle_authentication_call(conn)
	end

	post config(:admin_endpoint) do
		case System.get_env("MIX_ENV") == "dev" do
			false -> conn |> send_resp(404, "")
			true -> AdminController.add_secret(conn)
		end
	end

	# Everything else goes here... 
	match _ do
		send_resp(conn, 404, "")
	end
end