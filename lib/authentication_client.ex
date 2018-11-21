defmodule Yudhisthira.AuthenticationClient do
  alias Yudhisthira.Utils.Config
  alias Yudhisthira.Utils.Headers
  alias Yudhisthira.Utils.Codec
  alias Yudhisthira.Auth.SmpAuth

  def create_url(host, port) do
    http_proto = case System.get_env("SSL_ENABLED") do
      nil -> "http"
      _ -> "https"
    end

    "#{http_proto}://#{host}:#{port}#{Config.config(:authentication_endpoint)}"
  end

  def authenticate(host, port, secret) do
    # TODO: Clean up...

    # Sessionize
    response = HTTPotion.post(
      create_url(host, port),
      [
        headers: Headers.assign_host_headers()
      ]
    )

    true = HTTPotion.Response.success?(response)
    session_id = response.headers[Headers.get_header_from_config(:session_header)]

    # Step 1
    {:ok, auth_data_step_1, number_map_to_keep} = SmpAuth.create_data_for_auth()
    auth_data_step_1 = auth_data_step_1 |> Codec.encode_for_transit()
    
    response = HTTPotion.post(
      create_url(host, port),
      [
        headers:
          Headers.assign_host_headers() |>
          Headers.assign_session_headers(session_id) |>
          Headers.assign_auth_data_header(auth_data_step_1)
      ]
    )

    # Step 2 -- Coming back
    true = HTTPotion.Response.success?(response)
    session_id = response.headers[Headers.get_header_from_config(:session_header)]
    auth_data_step_2 = response.headers[Headers.get_header_from_config(:auth_data_header)] |>
      Codec.decode_from_transit()

    # Step 3
    new_number_map = Map.merge(number_map_to_keep, %{secret: secret})
    {:ok, auth_data_step_3, number_map_to_keep_3} = SmpAuth.create_data_for_auth(
      auth_data_step_2,
      new_number_map
    )

    # IO.inspect(auth_data_step_3)

    auth_data_step_3 = auth_data_step_3 |> Codec.encode_for_transit()

    response = HTTPotion.post(
      create_url(host, port),
      [
        headers:
          Headers.assign_host_headers() |>
          Headers.assign_session_headers(session_id) |>
          Headers.assign_auth_data_header(auth_data_step_3)
      ]
    )
    
    # Step 4 -- Coming back
    true = HTTPotion.Response.success?(response)
    session_id = response.headers[Headers.get_header_from_config(:session_header)]
    
    # IO.inspect(number_map_to_keep)
    # IO.inspect(number_map_to_keep_3)
    auth_data_step_4 = response.headers[Headers.get_header_from_config(:auth_data_header)] |>
      Codec.decode_from_transit()
    
    # IO.inspect(auth_data_step_4)

    SmpAuth.check_auth_data_final(
      auth_data_step_4["rb"],
      auth_data_step_4["c8"],
      auth_data_step_4["d10"],
      number_map_to_keep.x3,
      number_map_to_keep_3.pa,
      number_map_to_keep_3.pb,
      number_map_to_keep_3.g3b,
      number_map_to_keep_3.qa,
      number_map_to_keep_3.qb
    )
  end

  def authenticate(node, secret) do
    authenticate(node.ip_address, node.port, secret)
  end
end