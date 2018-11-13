defmodule YudhisthiraTest do
  use ExUnit.Case
  doctest Yudhisthira

  test "greets the world" do
    assert Yudhisthira.hello() == :world
  end
end
