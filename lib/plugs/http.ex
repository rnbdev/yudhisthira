defmodule Yudhisthira.Plugs.Http do
	use Plug.Router
	# import Poison, only: [decode: 1, encode: 1]

	# alias Plug.Conn
	alias Yudhisthira.Utils.Headers
	alias Yudhisthira.AuthenticationServer

	plug :match
	plug :dispatch
	
	post Application.get_env(:yudhisthira, :authentication_endpoint) do
		headers = conn.req_headers

		# To throw error, like a stereotypical man!
		true = Headers.identification_headers_exist?(headers)

		session_id = case Headers.get_session_id(headers) do
			nil -> AuthenticationServer.create_new_session()
			session_id -> AuthenticationServer.get_session(session_id)
		end
		IO.inspect(session_id)
		conn = case session_id do
			nil -> conn |> put_req_header(
				Headers.get_header_from_config(:auth_header),
				"Bad-Session"
			)
			session_id -> conn |> put_req_header(
				Headers.get_header_from_config(:session_header),
				session_id
			) |> put_req_header(
				Headers.get_header_from_config(:auth_header),
				"Authed"
			)
		end
		
		conn |> send_resp(200, "")
	end

	# Everything else goes here... really
	match _ do
		send_resp(conn, 400, "")
	end
end