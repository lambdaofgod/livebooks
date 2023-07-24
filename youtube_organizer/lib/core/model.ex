defmodule YTOrg.YoutubePlaylistMetadata do
  @enforce_keys [:id, :title]
  defstruct [:id, :title, :channel_id]
end

defmodule YTOrg.YoutubeVideo do
  defstruct [:id, :title, :url, :description, :thumbnails, :playlist_item_id]
end

defmodule YTOrg.YoutubePlaylist do
  defstruct [:metadata, :videos, :representing_video]
end
