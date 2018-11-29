defmodule Yudhisthira.Utils.Math do
  def pow(x, n) do
    pow(x, n, 0)
  end

  def pow(x, n, mod) do
    :crypto.mod_pow(x, n, mod) |> 
      :crypto.bytes_to_integer()
  end

  def mulm(x, y, mod) do
    rem(x * y, mod)
  end

  def sha256(message) do
    :crypto.hash(:sha256, message) |>
      :crypto.bytes_to_integer()
  end

  def create_random_exponent() do
    :crypto.strong_rand_bytes(192) |>
      :crypto.bytes_to_integer()
  end
end