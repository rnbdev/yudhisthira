defmodule Yudhisthira.Utils.Headers do
  alias Yudhisthira.Utils.Config

  def get_header_from_config(header_name) do
    "#{Config.config(:header_prefix)}-#{Config.config(header_name)}"
  end

  def assign_host_headers(headers \\ []) do
    headers ++ [
      "#{get_header_from_config(:hostname_header)}": System.get_env("HOST_NAME"),
      "#{get_header_from_config(:hostport_header)}": System.get_env("HOST_PORT"),
      "#{get_header_from_config(:hostid_header)}": System.get_env("HOST_ID") # TODO: Maybe not? Unused for now
    ]
  end

  def assign_session_headers(headers, session_id) do
    headers ++ [
      "#{get_header_from_config(:session_header)}": session_id
    ]
  end

  @doc """
  Gets headers as a list of tuples...
  """
  def get_session_id(headers) do
    case Enum.find(headers, fn header_kv ->
      {header, _} = header_kv
      cond do
        header == String.downcase(get_header_from_config(:session_header)) -> true
        true -> nil
      end
    end) do
      {_, session_id} -> session_id
      _ -> nil
    end
  end
end