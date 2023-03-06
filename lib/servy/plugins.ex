defmodule Servy.Plugins do
  require Logger
  alias Servy.Conv, as: Conv

  def track(%{http_status_code: 404, path: path} = conv) do
    Logger.warning("Path #{path} not found")
    conv
  end

  def track(%Conv{status_code: status_code, path: path} = conv) do
    Logger.info("#{path} #{Conv.status_reason(status_code)} #{status_code}")
    conv
  end

  def rewrite_path(%Conv{path: "/bel"} = conv),
    do: %Conv{conv | path: "/belchior"}

  def rewrite_path(%Conv{} = conv),
    do: conv

  def log(conv), do: IO.inspect(conv)
end
