defmodule Yudhisthira.Utils.Codec do
  def encode_for_transit(payload) when is_map(payload) do
    {:ok, payload |> Poison.encode!() |> Base.encode64()}
  end

  def encode_for_transit(payload) when is_bitstring(payload) do
    {:ok, payload |> Base.encode64()}
  end

  def decode_from_transit(data) do
    case Base.decode64(data) do
      {:ok, data_string} -> case Poison.decode(data_string) do
        {:ok, data_map} -> {:ok, data_map}
        {:error, _} -> {:ok, data_string}
      end
      {:error, _} -> {:error, :badrequest}
    end
  end

  def encode_secret(secret) when is_bitstring(secret) do
    secret |> Base.encode16() |> Integer.parse(16) |> elem(0) 
  end
end