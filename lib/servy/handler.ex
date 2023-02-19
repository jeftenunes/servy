defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse()
    |> route()
    |> format_response()
  end

  def parse(request) do
    # conv = Conversation
    # TODO: Parse the request string into a map:
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.trim()
      |> String.split(" ")

    %{method: method, path: path, resp_body: ""}
  end

  def route(conv) do
    # TODO: Create a new map that also has the response body:

    conv = %{method: "GET", path: "/wildthings", response_body: "Bears, Lions, Tigers"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Bears, Lions, Tigers
    """
  end
end

# request = """
#   GET /wildthings HTTP/1.1
#   HOST: exemple.com
#   User-Agent: ExampleBrowser/1.0
#   Accept: */*

# """

# expected_response = """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 20

# Bears, Lions, Tigers
# """

# response = Servy.Handler.handle(request)

# IO.puts(response)
# Request=
## Primeira linha Request line, GET => metodo http, path e protocolo http
## Key value pair: host, a chave e o host q esta sendo requestado
## User agent: software q faz a requisicao, tipicamente um browser
## accept: Media type aceita tudo (*/* wild card)

## Linha em branco importante separa os headers do body
