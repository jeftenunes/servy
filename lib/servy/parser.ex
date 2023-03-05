defmodule Servy.Parser do
  alias Servy.Conv, as: Conv

  def parse(req) do
    # conv = Conversation
    # TODO: Parse the request string into a map:
    [method, path, _] =
      req
      |> String.split("\n")
      |> List.first()
      |> String.trim()
      |> String.split(" ")

    %Conv{method: method, path: path, resp_body: "", status_code: nil}
  end
end
