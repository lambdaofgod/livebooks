defmodule YTOrg.YoutubePlaylistMetadata do
  @enforce_keys [:id, :title]
  defstruct [:id, :title, :channel_id]
end

defmodule YTOrg.YoutubeVideo do
  defstruct [
    :id,
    :title,
    :url,
    :description,
    :thumbnails,
    :playlist_item_id,
    :published_at,
    :channel_id,
    :channel_title,
    :channel_url
  ]
end

defmodule YTOrg.YoutubePlaylist do
  defstruct [:metadata, :videos, :representing_video]
end
