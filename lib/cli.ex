defmodule Yudhisthira.CLI do
  require Logger
  def start do
    # DEBUG
    IO.inspect(OptionParser.parse(System.argv()))

    Application.ensure_all_started(:yudhisthira)
  end

  def authenticate do
    IO.puts("Not implemented")
  end
end