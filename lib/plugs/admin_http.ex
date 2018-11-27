defmodule Yudhisthira.Plugs.AdminHttp do
	use Plug.Router
	import Yudhisthira.Utils.Router, only: [admin_endpoint: 1]
	alias Yudhisthira.Controllers.AdminController

	plug :match
	plug :dispatch

	get admin_endpoint(:secrets_endpoint) do
    	AdminController.list_secret(conn)
	end

	post admin_endpoint(:secrets_endpoint) do
    	AdminController.add_secret(conn)
	end

	delete admin_endpoint(:secrets_endpoint) do
		AdminController.delete_secret(conn)
	end

	get admin_endpoint(:peers_endpoint) do
		AdminController.list_peers(conn)
	end

	post admin_endpoint(:peers_endpoint) do
		AdminController.add_peer(conn)
	end

	delete admin_endpoint(:peers_endpoint) do
		AdminController.delete_peer(conn)
	end

	# Everything else goes here... 
	match _ do
		send_resp(conn, 404, "")
	end
end