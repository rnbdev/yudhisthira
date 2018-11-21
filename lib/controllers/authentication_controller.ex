defmodule Yudhisthira.Controllers.AuthenticationController do
  import Plug.Conn, only: [put_resp_header: 3, send_resp: 3]
	alias Yudhisthira.Utils.Headers
	alias Yudhisthira.Utils.Codec
	alias Yudhisthira.Servers.AuthenticationServer
	alias Yudhisthira.Structs.NetworkNode
	alias Yudhisthira.Auth.SmpAuth

	def create_auth_data(auth_data, auth_map) when (auth_data != nil) do
			SmpAuth.create_data_for_auth(auth_data, auth_map)
	end
  
  def handle_authentication_call(conn) do
    headers = conn.req_headers

		# Throws an error... if not ID headers exist
		# In the future, can be used to identify nodes from pure-clients
		true = Headers.identification_headers_exist?(headers)

		node = NetworkNode.create(
			Headers.get_node_address(headers),
			Headers.get_node_port(headers)
		)

		case Headers.get_session_id(headers) do
			nil ->
				{:ok, new_session_id} = AuthenticationServer.create_new_session(node)
				conn |> put_resp_header(
					Headers.get_header_from_config(:session_header),
					new_session_id
				)
			session_id -> 
				{session_node, number_map} = AuthenticationServer.get_session_data(
					session_id,
					node
				)
				case session_node do
					nil -> conn |> put_resp_header(
						Headers.get_header_from_config(:auth_header),
						"No-Auth" # TODO: Make it better
					)
					_ ->
						secret = System.get_env("SECRET") |> Base.encode16() |> Integer.parse(16) |> Kernel.elem(0)
						{:ok, auth_data_map, new_number_map} = 
							Headers.get_auth_data(headers) |> 
							Codec.decode_from_transit() |> 
							create_auth_data(
								Map.merge(
									number_map,
									%{secret: secret}
								)
							)

						AuthenticationServer.set_session_data(
							session_id,
							node,
							Map.merge(
								number_map,
								new_number_map
							)
						)

						auth_data_header_value = auth_data_map |> Codec.encode_for_transit()

						conn |>
							put_resp_header(
								Headers.get_header_from_config(:session_header),
								session_id
							) |>
							put_resp_header(
								Headers.get_header_from_config(:auth_data_header),
								auth_data_header_value
							)
				end
		end |> send_resp(200, "")
  end
end