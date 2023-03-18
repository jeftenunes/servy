defmodule Servy.Handler do
  @moduledoc """
  Handles http requests
  """

  require Logger
  alias Servy.Conv, as: Conv
  import Servy.Parser, only: [parse: 1]
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  alias Servy.Controllers.AlbumsController, as: AlbumController

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

  def emojify(%Conv{status_code: 200, resp_body: response_body} = conv),
    do: %Conv{conv | resp_body: "#{response_body} 🎉"}

  def emojify(%Conv{method: _, status_code: _, resp_body: _, path: _} = conv),
    do: conv

  def route(%Conv{method: "DELETE", path: "/belchior"} = conv),
    do: %Conv{conv | resp_body: "Belchior must not be deleted", status_code: 403}

  # def route(%{method: "DELETE", path: _} = conv),
  #   do: %{conv | resp_body: "", http_status_code: 204}

  def route(%Conv{method: "GET", path: "/belchior"} = conv),
    do: %Conv{conv | resp_body: "Pequeno mapa do tempo", status_code: 200}

  def route(%Conv{method: "GET", path: "/amelinha"} = conv),
    do: %Conv{conv | resp_body: "Foi deus", status_code: 200}

  def route(%Conv{method: "GET", path: "/artists/" <> id} = conv),
    do: %Conv{conv | resp_body: "artist id #{id}", status_code: 200}

  def route(%Conv{method: "GET", path: "/albums/"} = conv),
    do: AlbumController.index(conv)

  def route(%Conv{method: "GET", path: "/albums/" <> id} = conv),
    do: AlbumController.edit(conv, %{"id" => id})

  def route(%Conv{method: "POST", path: "/albums/"} = conv),
    do: AlbumController.create(conv, conv.params)

  def route(%Conv{method: "DELETE", path: "/albums/"} = conv),
    do: AlbumController.delete(conv, conv.params)

  def route(%Conv{method: "GET", path: "/pages" <> page} = conv) do
    @pages_path
    |> Path.join(page)
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: _, path: path} = conv),
    do: %Conv{conv | resp_body: "#{path} not found", status_code: 404}

  defp handle_file({:ok, contents}, conv),
    do: %Conv{conv | resp_body: contents, status_code: 200}

  defp handle_file({:error, :enoent}, %Conv{path: path} = conv),
    do: %Conv{conv | resp_body: "#{path} not found", status_code: 404}

  defp handle_file({:error, reason}, %Conv{path: path} = conv),
    do: %Conv{
      conv
      | resp_body: "InternalServerError searching #{path} - #{reason}",
        status_code: 500
    }

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{conv.status_code} #{Conv.status_reason(conv.status_code)}
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
