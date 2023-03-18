defmodule Servy.Models.Album do
  defstruct id: nil, name: nil, artist: nil

  def retrieve(), do: list_albums()

  def retrieve(id) do
    list_albums()
    |> Stream.filter(fn item -> item.id == id end)
    |> Enum.map(fn item -> item end)
  end

  defp list_albums do
    [
      %__MODULE__{id: 0, name: "Album 1", artist: "Belchior"},
      %__MODULE__{id: 1, name: "Album 2", artist: "Mano brown"},
      %__MODULE__{id: 2, name: "Album 3", artist: "Banda calypso"}
    ]
  end

  # defstruct auto_id: 0, entries: %{}

  # def retrieve(albums), do: albums.entries

  # def retrieve(albums, id),
  #   do:
  #     albums.entries
  #     |> Stream.filter(fn {_, entry} -> entry.id == id end)
  #     |> Enum.map(fn {_, item} -> item end)

  # def create(albums, %{"name" => name, "artist" => artist}) do
  #   entry = %{name: name, artist: artist}
  #   entry = Map.put(entry, :id, albums.auto_id)
  #   new_entries = Map.put(albums.entries, albums.auto_id, entry)
  #   %__MODULE__{albums | entries: new_entries, auto_id: albums.auto_id + 1}
  # end
end
