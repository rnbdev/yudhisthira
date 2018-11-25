defmodule Yudhisthira.Controllers.AdminController do
  require Logger
  import Plug.Conn, only: [read_body: 1, resp: 3, send_resp: 3, send_resp: 1]
  alias Yudhisthira.Servers.SecretsRepo

  def send_ok(conn) do
    conn |> resp(200, Poison.encode!(%{ok: true}))
  end

  def add_secret(conn) do
    Logger.info("Adding secret")
    {:ok, body, conn} = conn |> read_body()
    case Poison.decode(body) do
      {:ok, kv_map} -> case kv_map do
          %{"key" => key, "secret" => secret} ->
            SecretsRepo.create_secret(key, secret)
            send_ok(conn)
          _ -> 
            conn |> resp(400, "")
        end
      {:error, e} -> 
        IO.inspect(e)
        conn |> resp(400, "")
    end |> send_resp()
  end

  def list_secret(conn) do
    {:ok, encoded_data} = SecretsRepo.get_all_secrets() |> 
      Enum.map(fn {k, v} ->
        %{
          "key" => k,
          "secret" => v
        }
      end)
    |> Poison.encode()
    conn |> send_resp(200, encoded_data)
  end

  def delete_secret(conn) do
    Logger.info("Deleting secret")
    {:ok, body, conn} = conn |> read_body()
    case Poison.decode(body) do
      {:ok, kv_map} -> case kv_map do
        %{"key" => key} ->
          :ok = SecretsRepo.delete_secret(key)
          send_ok(conn)
        _ -> 
          conn |> resp(400, "")
      end
    end
  end
end