defmodule Servy.Parser do
  alias Servy.Conv, as: Conv

  def parse(req) do
    # conv = Conversation
    # TODO: Parse the request string into a map:
    [top, params_str] = String.split(req, "\n\n")
    [req_line | header_lines] = String.split(top, "\n")
    [method, path, _] = req_line |> String.trim() |> String.split(" ")

    parsed_headers = parse_headers(header_lines, %{})

    %Conv{
      path: path,
      resp_body: "",
      method: method,
      status_code: nil,
      headers: parsed_headers,
      params: parse_qry_params(parsed_headers["Content-Type"], params_str)
    }
  end

  defp parse_qry_params("application/x-www-form-urlencoded", params_str),
    do: params_str |> String.trim() |> URI.decode_query()

  defp parse_qry_params(_, _), do: %{}

  # defp parse_headers(header_lines) do
  #   Enum.reduce(header_lines, %{}, fn header_line, acc ->
  #     [name, value] = header_line |> String.split(": ")
  #     Map.put(acc, name, value)
  #   end)
  # end

  defp parse_headers([], acc), do: acc

  defp parse_headers([curr | others], acc) do
    [name, value] = curr |> String.split(": ")
    parse_headers(others, Map.put(acc, name, value))
  end
end
