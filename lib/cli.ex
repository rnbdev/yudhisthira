defmodule Yudhisthira.CLI do
  import Yudhisthira.Utils.Config, only: [find_from_args: 1, config: 1]
  import Yudhisthira.Utils.Router, only: [admin_endpoint: 1]
  alias Yudhisthira.Utils.Codec
  require Logger

  def run do
    Application.ensure_all_started(:yudhisthira)
  end

  def http_proto() do
    case config(:ssl_enabled) do
      true -> "https"
      false -> "http"
    end   
  end

  def create_url_for_secret_management() do
    host = config(:http_host)
    port = config(:admin_port)
    "#{http_proto()}://#{host}:#{port}#{admin_endpoint(:secrets_endpoint)}"
  end

  def create_url_for_peer_management() do
    host = config(:http_host)
    port = config(:admin_port)
    "#{http_proto()}://#{host}:#{port}#{admin_endpoint(:peers_endpoint)}"
  end

  # Peers
  def add_peer do
    response = HTTPotion.post(
      create_url_for_peer_management(),
      [
        body: Poison.encode!(%{
          "host" => find_from_args(:peer_host),
          "port" => find_from_args(:peer_port)
        })
      ]
    )

    case HTTPotion.Response.success?(response) do
      true -> IO.puts("Peer added")
      false -> IO.inspect(response)
    end
  end

  def delete_peer do
    response = HTTPotion.post(
      create_url_for_peer_management(),
      [
        body: Poison.encode!(%{
          "host" => find_from_args(:peer_host),
          "port" => find_from_args(:peer_port)
        })
      ]
    )

    case HTTPotion.Response.success?(response) do
      true -> IO.puts("Peer deleted")
      false -> IO.inspect(response)
    end
  end

  def list_peers do
    response = HTTPotion.get(
      create_url_for_peer_management()
    ) 
    
    case HTTPotion.Response.success?(response) do
      true -> IO.inspect(
        Poison.decode!(response.body)
      )
      false -> IO.inspect(response)
    end
  end

  # Secrets
  def add_secret do
    response = HTTPotion.post(
      create_url_for_secret_management(),
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
      create_url_for_secret_management()
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
      create_url_for_secret_management(),
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

  # Authentication
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

      {:addpeer, find_from_args(:add_peer)},
      {:deletepeer, find_from_args(:delete_peer)},
      {:listpeers, find_from_args(:list_peers)},

      {:authenticate, find_from_args(:authenticate)}
    ]

    case Enum.find(arg_list, fn {_, d} -> !!d end) do
      {:addsecret, true} -> add_secret()
      {:listsecrets, true} -> list_secrets()
      {:deletesecret, true} -> delete_secret()

      {:addpeer, true} -> add_peer()
      {:deletepeer, true} -> delete_peer()
      {:listpeers, true} -> list_peers()

      {:authenticate, true} -> authenticate()
    end
  end
end