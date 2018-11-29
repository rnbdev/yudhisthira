defmodule Yudhisthira.Utils.Config do
  @config_to_arg_map %{
    http_host: :host,
    http_port: :port,
    host_port: :port,
    ssl_enabled: :https,
    secret: :secret,
    secret_key: :secret_key, # Only for CLI
    port: :port, # Only for CLI
    admin_port: :admin_port # Only for CLI
  }

  def special_mapper(symbol, value) do
    case symbol do
      :http_port ->
        cond do
          is_bitstring(value) -> Integer.parse(value) |> elem(0)
          true -> value
        end
      :host_port ->
        cond do
          is_bitstring(value) -> Integer.parse(value) |> elem(0)
          true -> value
        end
      :port ->
        cond do
          is_bitstring(value) -> Integer.parse(value) |> elem(0)
          true -> value
        end
      _ -> value
    end
  end

  def find_from_args(arg_name) do
    {arg_list, _, _} = OptionParser.parse(System.argv(), switches: [])
    case Enum.find(arg_list, fn {a_name, _} -> 
      arg_name == a_name
    end) do
      {_, arg_val} -> arg_val
      _ -> nil
    end
  end
  
  def config(symbol) do
    config_value = case Map.get(@config_to_arg_map, symbol) do
      nil -> Application.get_env(:yudhisthira, symbol)
      x -> case find_from_args(x) do
        nil -> Application.get_env(:yudhisthira, symbol)
        y -> y
      end
    end
    special_mapper(symbol, config_value)
  end
end