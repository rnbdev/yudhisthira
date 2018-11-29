defmodule YudhisthiraTest.Utils.Headers do
  use ExUnit.Case
  alias Yudhisthira.Utils.Headers

  test "get_header_from_config gets header from configuration" do
    assert(
      Headers.get_header_from_config(:hostname_header) == 
      "X-Yudhisthira-Hostname"
    )
  end
end
