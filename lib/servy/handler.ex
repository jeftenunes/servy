defmodule Servy.Handler do
  require Logger

  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> emojify()
    |> track()
    |> format_response()
  end

  def emojify(%{http_status_code: 200, resp_body: response_body} = conv),
    do: %{conv | resp_body: "#{response_body} 🎉"}

  def emojify(%{method: _, http_status_code: _, resp_body: _, path: _} = conv),
    do: conv

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

  def rewrite_path(%{path: "/bel"} = conv),
    do: %{conv | path: "/belchior"}

  def rewrite_path(conv),
    do: conv

  def route(%{method: "DELETE", path: "/belchior"} = conv),
    do: %{conv | resp_body: "Belchior must not be deleted", http_status_code: 403}

  def route(%{method: "DELETE", path: _} = conv),
    do: %{conv | resp_body: "", http_status_code: 204}

  def route(%{method: "GET", path: "/belchior"} = conv),
    do: %{conv | resp_body: "Pequeno mapa do tempo", http_status_code: 200}

  def route(%{method: "GET", path: "/amelinha"} = conv),
    do: %{conv | resp_body: "Foi deus", http_status_code: 200}

  def route(%{method: "GET", path: "/artists/" <> id} = conv),
    do: %{conv | resp_body: "artist id #{id}", http_status_code: 200}

  def route(%{method: "GET", path: "/pages" <> page} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join(page)
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{method: _, path: path} = conv),
    do: %{conv | resp_body: "#{path} not found", http_status_code: 404}

  # def route(%{method: "GET", path: path} = conv) do
  #   regex = ~r{\/(?<resource>\w+)\/id\/(?<id>\d+)}
  #   captures = Regex.named_captures(regex, path)

  #   route_extract_path(conv, captures)
  # end

  defp handle_file({:ok, contents}, conv),
    do: %{conv | resp_body: contents, http_status_code: 200}

  defp handle_file({:error, :enoent}, %{path: path} = conv),
    do: %{conv | resp_body: "#{path} not found", http_status_code: 404}

  defp handle_file({:error, reason}, %{path: path} = conv),
    do: %{
      conv
      | resp_body: "InternalServerError searching #{path} - #{reason}",
        http_status_code: 500
    }

  def track(%{http_status_code: 404, path: path} = conv) do
    Logger.warning("Path #{path} not found")
    conv
  end

  def track(%{http_status_code: status_code, path: path} = conv) do
    Logger.info("#{path} #{status_reason(status_code)} #{status_code}")
    conv
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.http_status_code} #{status_reason(conv.http_status_code)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(http_status_code) do
    %{
      200 => "OK",
      201 => "Created",
      204 => "NoContent",
      400 => "BadRequest",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "NotFound",
      500 => "InternaServerError"
    }[http_status_code]
  end

  defp route_extract_path(conv, nil), do: conv

  defp route_extract_path(conv, %{"id" => id, "resource" => resource}),
    do: %{
      conv
      | path: "/#{resource}/#{id}",
        resp_body: "#{resource} id #{id}",
        http_status_code: 200
    }
end

# request_bears = """
#   GET /bears HTTP/1.1
#   HOST: exemple.com
#   User-Agent: ExampleBrowser/1.0
#   Accept: */*
# """

# delete = """
#   DELETE /bears HTTP/1.1
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
