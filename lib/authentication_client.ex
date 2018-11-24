defmodule Yudhisthira.AuthenticationClient do
  alias Yudhisthira.Utils.Config
  alias Yudhisthira.Utils.Headers
  alias Yudhisthira.Utils.Codec
  alias Yudhisthira.Auth.SmpAuth

  def create_url(host, port) do
    "#{host}:#{port}#{Config.config(:authentication_endpoint)}"
  end

  def sessionize(host, port) do
    HTTPotion.get(
      create_url(host, port),
      [
        headers: Headers.assign_host_headers()
      ]
    )
  end

  def sessionize(host, port, secret_key) do
    HTTPotion.get(
      create_url(host, port),
      [
        headers: Headers.assign_host_headers() |>
          Headers.assign_secret_key_header(secret_key |> Codec.encode_for_transit())
      ]
    )
  end

  def authenticate(host, port, secret) do
    sessionize(host, port) |> authenticate_smp(host, port, secret)
  end

  def authenticate(host, port, secret_key, secret) do
    # Sessionize
    sessionize(host, port, secret_key) |> authenticate_smp(host, port, secret)
  end

  defp authenticate_smp(session_response, host, port, secret) do
    true = HTTPotion.Response.success?(session_response)
    session_id = session_response.headers[Headers.get_header_from_config(:session_header)]

    # Step 1
    {:ok, auth_data_step_1, number_map_to_keep} = SmpAuth.create_data_for_auth()
    {:ok, auth_data_step_1} = auth_data_step_1 |> Codec.encode_for_transit()

    IO.inspect(session_response)
    
    response = HTTPotion.get(
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
    {:ok, auth_data_step_2} = response.headers[Headers.get_header_from_config(:auth_data_header)] |>
      Codec.decode_from_transit()

    # Step 3
    new_number_map = Map.merge(number_map_to_keep, %{secret: secret})
    {:ok, auth_data_step_3, number_map_to_keep_3} = SmpAuth.create_data_for_auth(
      auth_data_step_2,
      new_number_map
    )

    {:ok, auth_data_step_3} = auth_data_step_3 |> Codec.encode_for_transit()

    response = HTTPotion.get(
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
    
    {:ok, auth_data_step_4} = response.headers[Headers.get_header_from_config(:auth_data_header)] |>
      Codec.decode_from_transit()

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
end