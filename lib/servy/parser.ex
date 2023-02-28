defmodule Servy.Parser do
  def parse(req) do
    # conv = Conversation
    # TODO: Parse the request string into a map:
    [method, path, _] =
      req
      |> String.split("\n")
      |> List.first()
      |> String.trim()
      |> String.split(" ")

    %{method: method, path: path, resp_body: "", http_status_code: nil}
  end
end
