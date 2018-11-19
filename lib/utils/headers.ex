defmodule Yudhisthira.Utils.Headers do
  alias Yudhisthira.Utils.Config

  def get_header_from_config(header_name) do
    String.downcase("#{Config.config(:header_prefix)}-#{Config.config(header_name)}")
  end

  # Assignment to a key:value list...
  def assign_host_headers(headers \\ []) do
    headers ++ [
      "#{get_header_from_config(:hostname_header)}": System.get_env("HOST_NAME"),
      "#{get_header_from_config(:hostport_header)}": System.get_env("HOST_PORT"),
      "#{get_header_from_config(:hostid_header)}": System.get_env("HOST_ID")
    ]
  end

  def assign_session_headers(headers, session_id) do
    headers ++ [
      "#{get_header_from_config(:session_header)}": session_id
    ]
  end

  def assign_auth_data_header(headers, auth_data) do
    headers ++ [
      "#{get_header_from_config(:auth_data_header)}": auth_data
    ]
  end

  # Does not take care of spaces and don't separate them as lists
  # Takes everything and shoves it out
  def get_header_value(headers, header_symbol) do
    case Enum.find(headers, fn header_kv ->
      {header, _} = header_kv
      cond do
        header == get_header_from_config(header_symbol) -> true
        true -> nil
      end
    end) do
      {_, header_value} -> case String.trim(header_value) do
        "" -> nil
        _ -> header_value
      end
      _ -> nil
    end
  end

  @doc """
  Gets header values
  """
  def get_session_id(headers) do
    headers |> get_header_value(:session_header)
  end

  @doc """
  Gets header value
  """
  def get_node_id(headers) do
    headers |> get_header_value(:hostid_header)
  end

  @doc """
  Gets header value
  """
  def get_node_address(headers) do
    headers |> get_header_value(:hostname_header)
  end

  @doc """
  Gets header value
  """
  def get_auth_data(headers) do
    headers |> get_header_value(:auth_data_header)
  end

  @doc """
  Gets header value
  """
  def get_node_port(headers) do
    headers |> get_header_value(:hostport_header)
  end

  @doc """
  Gets headers as a list of tuples...
  """
  def identification_headers_exist?(headers) do
    (headers |> get_header_value(:hostid_header) != nil) and
    (headers |> get_header_value(:hostport_header) != nil) and
    (headers |> get_header_value(:hostname_header) != nil)
  end
end