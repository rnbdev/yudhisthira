defmodule Yudhisthira.AuthenticatorClient do
  import Poison, only: [decode: 1, encode: 1]
  alias Yudhisthira.Utils.Config

  def create_url(host, port) do
    http_proto = case System.get_env("SSL_ENABLED") do
      nil -> "http"
      _ -> "https"
    end

    "#{http_proto}://#{host}:#{port}/#{Config.config(:authentication_endpoint)}"
  end

  def authenticate(host, port, payload) do
    {:ok, body} = encode(payload)

    # TODO: Clean up...
    response = HTTPotion.post(
      create_url(host, port),
      [
        body: body,
        headers: [
          "Content-Type": "application/json"
        ]
      ]
    )

    case HTTPotion.Response.success?(response) do
      true -> analyze_authentication_payload(response.body)
      false -> {:error, response}
    end
  end

  def analyze_authentication_payload(authentication_payload) do
    {:ok, authentication_data} = decode(authentication_payload)
    case authentication_data do
      %{"auth" => true} -> {:ok, true}
      _ -> {:ok, false}
    end
  end
end