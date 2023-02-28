defmodule Servy.Common do
  def status_reason(http_status_code) do
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
end
