defmodule Yudhisthira.Utils.Ports do
  import Yudhisthira.Utils.Config, only: [config: 1]

  def find_free_admin_port do
    Enum.find(config(:admin_port)..(config(:admin_port) + config(:admin_port_range)), fn port_number ->
      case :gen_tcp.listen(port_number, []) do
        {:ok, port} ->
          Port.close(port)
          true
        {:error, _} -> false
      end
    end)
  end
end