defmodule Servy.Controllers.AlbumsController do
  alias Servy.Conv, as: Conv
  alias Servy.Models.Album, as: Albums

  @templates_path Path.expand("../../../templates", __DIR__)

  def index(conv),
    do: render(conv, "index.eex", albums: Albums.retrieve())

  def edit(conv, %{"id" => id}) do
    cast_id = id |> String.to_integer()

    album =
      Albums.retrieve()
      |> Stream.filter(&(&1.id == cast_id))
      |> Enum.map(& &1)
      |> List.first()

    render(conv, "edit.eex", album: album)
  end

  def create(conv, %{"name" => name, "artist" => artist}) do
    %Conv{
      conv
      | resp_body: "Album #{name} by #{artist} created",
        status_code: 201
    }
  end

  def delete(conv, _) do
    %Conv{
      conv
      | resp_body: "Deleting an album is forbidden",
        status_code: 403
    }
  end

  defp render(conv, template, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %Conv{conv | resp_body: content, status_code: 200}
  end
end
