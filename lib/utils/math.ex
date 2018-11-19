defmodule Yudhisthira.Utils.Math do
  def pow(x, n) do
    :crypto.mod_pow(x, n, 0)
  end

  def pow(x, n, mod) do
    :crypto.mod_pow(x, n, mod)
  end
end