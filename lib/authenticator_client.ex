defmodule Yudhisthira.AuthenticatorClient do
  import Poison, only: [decode: 1, encode: 1]

  def authenticate(address, payload) do
    {:ok, body} = encode(payload)
    response = HTTPotion.post(
      "#{address}/#{Application.get_env(:yudhisthira, :authentication_endpoint)}",
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