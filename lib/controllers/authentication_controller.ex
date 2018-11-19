defmodule Yudhisthira.Controllers.AuthenticationController do
  import Plug.Conn, only: [put_resp_header: 3, send_resp: 3]
	alias Yudhisthira.Utils.Headers
	alias Yudhisthira.AuthenticationServer
	alias Yudhisthira.Structs.NetworkNode
  
  def handle_authentication_call(conn) do
    headers = conn.req_headers

		# Throws an error... if not ID headers exist
		# In the future, can be used to identify nodes from pure-clients
		true = Headers.identification_headers_exist?(headers)

		node = NetworkNode.create(
			Headers.get_node_address(headers),
			Headers.get_node_port(headers),
			Headers.get_node_id(headers)
		)

		case Headers.get_session_id(headers) do
			nil ->
				new_session_id = AuthenticationServer.create_new_session(
					node,
					%{}
				)
				conn |> put_resp_header(
					Headers.get_header_from_config(:session_header),
					new_session_id
				)
			session_id -> 
				{session_node, _} = AuthenticationServer.get_session_data(
					session_id,
					node
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
end