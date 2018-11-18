defmodule Yudhisthira.Plugs.Http do
	use Plug.Router
	# import Poison, only: [decode: 1, encode: 1]

	import Plug.Conn, only: [put_resp_header: 3, send_resp: 3, get_req_header: 2]
	alias Yudhisthira.Utils.Headers
	alias Yudhisthira.AuthenticationServer
	alias Yudhisthira.Structs.NetworkNode

	plug :match
	plug :dispatch

	defp create_node_from_conn(conn) do
		%NetworkNode{
			ip_address: conn |> 
				get_req_header(Headers.get_header_from_config(:hostname_header)),
			port: conn |>
				get_req_header(Headers.get_header_from_config(:hostport_header)),
			id: conn |>
				get_req_header(Headers.get_header_from_config(:hostid_header)),
		}
	end
	
	post Application.get_env(:yudhisthira, :authentication_endpoint) do
		headers = conn.req_headers

		# To throw error, like a stereotypical man!
		true = Headers.identification_headers_exist?(headers)

		case Headers.get_session_id(headers) do
			nil ->
				new_session_id = AuthenticationServer.create_new_session(
					create_node_from_conn(conn)
				)
				conn |> put_resp_header(
					Headers.get_header_from_config(:session_header),
					new_session_id
				)
			session_id -> 
				session_node = AuthenticationServer.get_session_node(
					session_id,
					create_node_from_conn(conn)
				)
				case session_node do
					nil -> conn |> put_resp_header(
						Headers.get_header_from_config(:auth_header),
						"No-Auth" # TODO: Make it better
					)
					_ -> conn |> put_resp_header(
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