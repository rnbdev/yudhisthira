defmodule Yudhisthira.AuthenticationServer do
  def create_new_session do
    UUID.uuid4(:default)
  end

  def get_session(_sessionid) do
    "Some session"
  end
end