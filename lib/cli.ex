defmodule Yudhisthira.CLI do
  import Yudhisthira.Utils.Config, only: [find_from_args: 1, config: 1]
  alias Yudhisthira.Utils.Codec
  require Logger

  def run do
    Application.ensure_all_started(:yudhisthira)
  end

  def create_url_for_adding_secret(host, port) do
    http_proto = case config(:ssl_enabled) do
      true -> "https"
      false -> "http"
    end

    "#{http_proto}://#{host}:#{port}#{config(:admin_endpoint)}"
  end

  def add_secret do
    HTTPotion.start()
    HTTPotion.post(
      create_url_for_adding_secret(config(:http_host), config(:port)),
      [
        body: Poison.encode!(%{
          "key" => config(:secret_key),
          "secret" => config(:secret)
        })
      ]
    )
    IO.puts("Secret added")
  end

  def authenticate do
    host = config(:http_host)
    port = config(:port)
    secret_key = config(:secret_key)
    secret = config(:secret) |> Codec.encode_secret()

    HTTPotion.start()

    case Yudhisthira.AuthenticationClient.authenticate(host, port, secret_key, secret) do
      {:ok, :match} -> IO.puts("Secrets match")
      {:error, :nomatch} -> IO.puts("Secrets don't match")
    end
  end

  def start do
    arg_list = [
      {:addsecret, find_from_args(:addsecret)},
      {:authenticate, find_from_args(:authenticate)}
    ]

    case Enum.find(arg_list, fn {_, d} -> !!d end) do
      {:addsecret, true} -> add_secret()
      {:authenticate, true} -> authenticate()
    end
  end
end