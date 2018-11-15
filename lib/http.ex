defmodule Yudhisthira.Plugs.Http do
	use Plug.Router
	alias Plug.Conn

	import Poison, only: [decode: 1, encode: 1]

	plug :match
	plug :dispatch
	
	post Application.get_env(:yudhisthira, :authentication_endpoint) do
		{:ok, body_data, conn} = Conn.read_body(conn)
		{:ok, authentication_payload} = decode(body_data)
		{:ok, data} = encode(authentication_payload)

		conn |> 
			merge_resp_headers([
				{"Content-Type", "application/json"}
			]) |>
			send_resp(200, data)
	end

	# Everything else goes here... really
	match _ do
		send_resp(conn, 400, "")
	end
end