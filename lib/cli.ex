defmodule Yudhisthira.CLI do
  import Yudhisthira.Utils.Config, only: [find_from_args: 1, config: 1]
  alias Yudhisthira.Utils.Codec
  require Logger

  def run do
    Application.ensure_all_started(:yudhisthira)
  end

  def create_url_for_secret_management(host, port) do
    http_proto = case config(:ssl_enabled) do
      true -> "https"
      false -> "http"
    end

    "#{http_proto}://#{host}:#{port}#{config(:admin_endpoint)}"
  end

  def add_secret do
    response = HTTPotion.post(
      create_url_for_secret_management(config(:http_host), config(:port) || config(:http_port)),
      [
        body: Poison.encode!(%{
          "key" => find_from_args(:secret_key),
          "secret" => find_from_args(:secret_value)
        })
      ]
    )
    
    case HTTPotion.Response.success?(response) do
      true -> IO.puts("Secret added")
      false -> IO.inspect(response)
    end
  end

  def list_secrets do
    response = HTTPotion.get(
      create_url_for_secret_management(config(:http_host), config(:port) || config(:http_port))
    ) 
    
    case HTTPotion.Response.success?(response) do
      true -> IO.inspect(
        Poison.decode!(response.body)
      )
      false -> IO.inspect(response)
    end
  end

  def delete_secret do 
    response = HTTPotion.delete(
      create_url_for_secret_management(config(:http_host), config(:port) || config(:http_port)),
      [
        body: Poison.encode!(%{
          "key" => find_from_args(:secret_key)
        })
      ]
    )
    
    case HTTPotion.Response.success?(response) do
      true -> IO.puts("Secret deleted")
      false -> IO.inspect(response)
    end
  end

  def authenticate do
    host = config(:http_host)
    port = config(:port) || config(:http_port)
    secret_key = find_from_args(:secret_key)
    secret = find_from_args(:secret_value) |> Codec.encode_secret()

    case Yudhisthira.AuthenticationClient.authenticate(host, port, secret_key, secret) do
      {:ok, :match} -> IO.puts("Secrets match")
      {:error, :nomatch} -> IO.puts("Secrets don't match")
    end
  end

  def start do
    HTTPotion.start()

    arg_list = [
      {:addsecret, find_from_args(:add_secret)},
      {:addsecret, find_from_args(:update_secret)},
      {:listsecrets, find_from_args(:list_secrets)},
      {:deletesecret, find_from_args(:delete_secret)},
      {:authenticate, find_from_args(:authenticate)}
    ]

    case Enum.find(arg_list, fn {_, d} -> !!d end) do
      {:addsecret, true} -> add_secret()
      {:listsecrets, true} -> list_secrets()
      {:deletesecret, true} -> delete_secret()
      {:authenticate, true} -> authenticate()
    end
  end
end