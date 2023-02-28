defmodule Servy.Handler do
  @moduledoc """
  Handles http requests
  """

  alias Servy.Common, as: Common

  require Logger
  import Servy.Parser, only: [parse: 1]
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]

  @pages_path Path.expand("../../pages", __DIR__)

  @doc """
  Transform a request into a response
  """
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
    @pages_path
    |> Path.join(page)
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{method: _, path: path} = conv),
    do: %{conv | resp_body: "#{path} not found", http_status_code: 404}

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

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.http_status_code} #{Common.status_reason(conv.http_status_code)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  # def route(%{method: "GET", path: path} = conv) do
  #   regex = ~r{\/(?<resource>\w+)\/id\/(?<id>\d+)}
  #   captures = Regex.named_captures(regex, path)

  #   route_extract_path(conv, captures)
  # end

  # defp route_extract_path(conv, nil), do: conv

  # defp route_extract_path(conv, %{"id" => id, "resource" => resource}),
  #   do: %{
  #     conv
  #     | path: "/#{resource}/#{id}",
  #       resp_body: "#{resource} id #{id}",
  #       http_status_code: 200
  #   }
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
