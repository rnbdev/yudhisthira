defmodule Yudhisthira.Controllers.AdminController do
  import Plug.Conn, only: [read_body: 1, resp: 3, send_resp: 1]
  alias Yudhisthira.Servers.SecretsRepo

  def add_secret(conn) do
    {:ok, body, conn} = conn |> read_body()
    case Poison.decode(body) do
      {:ok, kv_map} -> case kv_map do
          %{"key" => key, "secret" => secret} ->
            SecretsRepo.create_secret(key, secret)
            conn |> resp(200, "OK")
          _ -> 
            conn |> resp(400, "")
        end
      {:error, e} -> 
        IO.inspect(e)
        conn |> resp(400, "")
    end |> send_resp()
  end
end