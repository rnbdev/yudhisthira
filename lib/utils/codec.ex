defmodule Yudhisthira.Utils.Codec do
  def encode_for_transit(payload) do
    {:ok, payload |> Poison.encode!() |> Base.encode64()}
  end

  def decode_from_transit(data) do
    case Base.decode64(data) do
      {:ok, data_string} -> Poison.decode(data_string)
      {:error, _} -> {:error, :badrequest}
    end
  end
end