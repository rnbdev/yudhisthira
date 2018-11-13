defmodule Yudhisthira.Poller do
    def start_link() do
        Agent.start_link(fn -> IO.puts("Hello World") end)
    end
end