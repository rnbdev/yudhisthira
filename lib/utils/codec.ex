defmodule Yudhisthira.Utils.Codec do
  def encode_for_transit(payload) do
    payload |> Poison.encode!() |> Base.encode64()
  end

  def decode_from_transit(data) do
    data |> Base.decode64!() |> Poison.decode!()
  end
end