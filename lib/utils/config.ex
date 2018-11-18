defmodule Yudhisthira.Utils.Config do
  def config(symbol) do
    Application.get_env(:yudhisthira, symbol)
  end
end