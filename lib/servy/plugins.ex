defmodule Servy.Plugins do
  require Logger
  import Servy.Common, only: [status_reason: 1]

  def track(%{http_status_code: 404, path: path} = conv) do
    Logger.warning("Path #{path} not found")
    conv
  end

  def track(%{http_status_code: status_code, path: path} = conv) do
    Logger.info("#{path} #{status_reason(status_code)} #{status_code}")
    conv
  end

  def rewrite_path(%{path: "/bel"} = conv),
    do: %{conv | path: "/belchior"}

  def rewrite_path(conv),
    do: conv

  def log(conv), do: IO.inspect(conv)
end
