defmodule Yudhisthira.AuthenticationClient do
  alias Yudhisthira.Utils.Config
  alias Yudhisthira.Utils.Headers
  alias Yudhisthira.Auth.SmpAuth

  def create_url(host, port) do
    http_proto = case System.get_env("SSL_ENABLED") do
      nil -> "http"
      _ -> "https"
    end

    "#{http_proto}://#{host}:#{port}#{Config.config(:authentication_endpoint)}"
  end

  def authenticate(host, port) do
    # TODO: Clean up...
    auth_data = 
      SmpAuth.create_data_for_step_1() |>
      Poison.encode!() |>
      Base.encode64()

    response = HTTPotion.post(
      create_url(host, port),
      [
        headers: 
          Headers.assign_host_headers() |>
          Headers.assign_auth_data_header(auth_data)
      ]
    )

    true = HTTPotion.Response.success?(response)
    session_id = response.headers[Headers.get_header_from_config(:session_header)]
    HTTPotion.post(
      create_url(host, port),
      [
        headers:
          Headers.assign_host_headers() |>
          Headers.assign_session_headers(session_id)
      ]
    )
  end

  def authenticate(node) do
    authenticate(node.ip_address, node.port)
  end
end