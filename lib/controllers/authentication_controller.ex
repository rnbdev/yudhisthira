defmodule Yudhisthira.Controllers.AuthenticationController do
  import Plug.Conn, only: [put_resp_header: 3, send_resp: 3]
	alias Yudhisthira.Utils.Headers
	alias Yudhisthira.Servers.AuthenticationServer
	alias Yudhisthira.Structs.NetworkNode
	alias Yudhisthira.Auth.SmpAuth

	def encode_for_transit(map) do
		map |>
			Poison.encode!() |>
			Base.encode64()
	end

	def auth_data_step(auth_data, _auth_map) do
		auth_data = Base.decode64!(auth_data) |> Poison.decode!()
		IO.inspect(auth_data)
		case auth_data do
			nil -> {:error, :no_data}
			_ -> SmpAuth.create_data_for_step_2_4(auth_data) |> encode_for_transit()
		end
	end
  
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
				{session_node, auth_map} = AuthenticationServer.get_session_data(
					session_id,
					node
				)
				case session_node do
					nil -> conn |> put_resp_header(
						Headers.get_header_from_config(:auth_header),
						"No-Auth" # TODO: Make it better
					)
					_ ->
						{:ok, auth_data} = 
							Headers.get_auth_data(headers) |> auth_data_step(auth_map)
						conn |>
							put_resp_header(
								Headers.get_header_from_config(:session_header),
								session_id
							) |>
							put_resp_header(
								Headers.get_header_from_config(:auth_data_header),
								auth_data
							)
				end
		end |> send_resp(200, "")
  end
end