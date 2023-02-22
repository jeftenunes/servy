defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> track()
    |> format_response()
  end

  def log(conv), do: IO.inspect(conv)

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

  def rewrite_path(%{path: "/wildlife"} = conv),
    do: %{conv | path: "/wildthings"}

  def rewrite_path(conv),
    do: conv

  def route(%{method: "GET", path: "/wildthings"} = conv),
    do: %{conv | resp_body: "Bears, Lions, Tigers", http_status_code: 200}

  def route(%{method: "GET", path: "/bears"} = conv),
    do: %{conv | resp_body: "Teddy, Smokey, Paddington", http_status_code: 200}

  def route(%{method: "GET", path: "/bears/" <> id} = conv),
    do: %{conv | resp_body: "Bear id #{id}", http_status_code: 200}

  def route(%{method: _, path: path} = conv),
    do: %{conv | resp_body: "#{path} not found", http_status_code: 404}

  def track(%{http_status_code: 200, path: path} = conv) do
    IO.puts("#{path} OK 200")
    conv
  end

  def track(%{http_status_code: 404, path: path} = conv) do
    IO.puts("Path #{path} not found")
    conv
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.http_status_code} #{status_reason(conv.http_status_code)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(http_status_code) do
    %{
      200 => "OK",
      201 => "Created",
      400 => "BadRequest",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "NotFound",
      500 => "InternaServerError"
    }[http_status_code]
  end
end

# request_bears = """
#   GET /bears HTTP/1.1
#   HOST: exemple.com
#   User-Agent: ExampleBrowser/1.0
#   Accept: */*
# """

# request_bigfoot = """
#   GET /bigfoot HTTP/1.1
#   HOST: exemple.com
#   User-Agent: ExampleBrowser/1.0
#   Accept: */*
# """

# request_wildthings = """
#   GET /wildlife HTTP/1.1
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

# by_id = """
#   GET /bears/1 HTTP/1.1
#   HOST: exemple.com
#   User-Agent: ExampleBrowser/1.0
#   Accept: */*
# """

# response = Servy.Handler.handle(request)

# IO.puts(response)
# Request=
## Primeira linha Request line, GET => metodo http, path e protocolo http
## Key value pair: host, a chave e o host q esta sendo requestado
## User agent: software q faz a requisicao, tipicamente um browser
## accept: Media type aceita tudo (*/* wild card)

## Linha em branco importante separa os headers do body
