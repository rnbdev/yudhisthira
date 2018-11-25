defmodule Yudhisthira.Controllers.AuthenticationController do
	import Plug.Conn, only: [put_resp_header: 3, send_resp: 1, resp: 3]
	import Yudhisthira.Utils.Config, only: [config: 1]
	require Logger
	alias Yudhisthira.Utils.Headers
	alias Yudhisthira.Utils.Codec
	alias Yudhisthira.Structs.NetworkNode
	alias Yudhisthira.Auth.SmpAuth
	alias Yudhisthira.Servers.AuthenticationServer
	alias Yudhisthira.Servers.SecretsRepo

	@secret config(:embedded_secret)

	def create_auth_data(auth_data, auth_map) do
		case auth_data do
			nil -> {:error, :badrequest}
			_ -> try do
				SmpAuth.create_data_for_auth(auth_data, auth_map)
			rescue
				e in MatchError -> {:error, :badrequest, e}
			end
		end
	end

	def resolve_secret(headers) do
		case headers |> Headers.get_secret_key() do
			nil -> {:ok, @secret |> Codec.encode_secret()}
			secret_key -> case SecretsRepo.get_secret(secret_key) do
				nil -> {:error, :badrequest}
				secret_value -> {:ok, secret_value |> Codec.encode_secret()}
			end
		end
	end

	def sessionize_incoming_connection(conn, node, secret_value) do
		{:ok, new_session_id} = AuthenticationServer.create_new_session(
			node,
			%{secret: secret_value}
		)
		conn |>
			put_resp_header(
				Headers.get_header_from_config(:session_header),
				new_session_id
			) |> resp(200, "")
	end
  
  def handle_authentication_call(conn) do
    headers = conn.req_headers

		node = NetworkNode.create(
			Headers.get_node_address(headers),
			Headers.get_node_port(headers)
		)

		case Headers.get_session_id(headers) do
			nil ->
				case resolve_secret(headers) do
					{:error, :badrequest} -> conn |> resp(400, "")
					{:ok, secret_value} -> conn |> sessionize_incoming_connection(node, secret_value)
				end
			session_id -> 
				{session_node, number_map} = AuthenticationServer.get_session_data(
					session_id,
					node
				)
				case session_node do
					nil -> conn |> resp(403, "")
					_ ->
						case Headers.get_auth_data(headers) |> Codec.decode_from_transit() do
							{:ok, auth_data} -> 
								case create_auth_data(auth_data, number_map) do
									{:ok, new_auth_data, new_number_map} -> 
										# TODO: Fire a notification and destroy the session!
										case new_number_map do
											%{match: x} -> case x do
												true -> Logger.info("MATCHED")
												false -> Logger.info("NOT MATCHED")
											end
											_ -> nil
										end
	
										:ok = AuthenticationServer.set_session_data(
											session_id,
											node,
											Map.merge(
												number_map,
												new_number_map
											)
										)
	
										{:ok, auth_data_header_value} = 
											new_auth_data |> Codec.encode_for_transit()
	
										conn |>
											put_resp_header(
												Headers.get_header_from_config(:session_header),
												session_id
											) |>
											put_resp_header(
												Headers.get_header_from_config(:auth_data_header),
												auth_data_header_value
											) |> resp(200, "")
									{:error, :badrequest, _} -> 
										conn |> resp(400, "")
								end
							{:error, :badrequest} -> 
								conn |> resp(400, "")
						end
				end
		end |> send_resp()
  end
end