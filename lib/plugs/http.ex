defmodule Yudhisthira.Plugs.Http do
	use Plug.Router
	import Poison, only: [decode: 1, encode: 1]

	alias Plug.Conn
	alias Yudhisthira.Utils.Headers

	plug :match
	plug :dispatch
	
	post Application.get_env(:yudhisthira, :authentication_endpoint) do
		headers = conn.req_headers
		IO.inspect(Headers.get_session_id(headers))
		
		# TODO: Enter Auth logic here
		# TODO: If authenticated add the node to inventory
		conn |> send_resp(200, "")
	end

	# Everything else goes here... really
	match _ do
		send_resp(conn, 400, "")
	end
end