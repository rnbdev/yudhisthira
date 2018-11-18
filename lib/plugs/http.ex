defmodule Yudhisthira.Plugs.Http do
	use Plug.Router
	# import Poison, only: [decode: 1, encode: 1]

	import Plug.Conn, only: [put_resp_header: 3, send_resp: 3]
	# alias Plug.Conn
	alias Yudhisthira.Utils.Headers
	alias Yudhisthira.AuthenticationServer

	plug :match
	plug :dispatch
	
	post Application.get_env(:yudhisthira, :authentication_endpoint) do
		headers = conn.req_headers

		# To throw error, like a stereotypical man!
		true = Headers.identification_headers_exist?(headers)
		case Headers.get_session_id(headers) do
			nil ->
				new_session_id = AuthenticationServer.create_new_session()
				conn |> put_resp_header(
					Headers.get_header_from_config(:session_header),
					new_session_id
				)
			session_id -> 
				session_id = AuthenticationServer.get_session(session_id)
				case session_id do
					nil -> conn |> put_resp_header(
						Headers.get_header_from_config(:auth_header),
						"No-Auth"
					)
					session_id -> conn |> put_resp_header(
						Headers.get_header_from_config(:session_header),
						session_id
					)
				end
		end |> send_resp(200, "")
	end

	# Everything else goes here... really
	match _ do
		send_resp(conn, 400, "")
	end
end