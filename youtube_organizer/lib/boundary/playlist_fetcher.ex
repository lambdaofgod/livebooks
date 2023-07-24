defmodule YTOrg.YoutubePlaylistFetcher do
  defstruct [:auth]

  alias YTOrg.{
    YoutubeRecordParser,
    AuthWrapper,
    YouTubeClient
  }

  def new(google_creds_path \\ "creds.json") do
    %YTOrg.YoutubePlaylistFetcher{auth: AuthWrapper.new(google_creds_path)}
  end

  def fetch_youtube_playlists(fetcher, max_results \\ 50) do
    for {metadata, playlist_videos} <- fetch_youtube_playlist_records(fetcher, max_results) do
      metadata |> YoutubeRecordParser.parse_playlist(playlist_videos)
    end
  end

  @doc ~S"""
  ## Examples
      iex> playlists = YoutubePlaylistFetcher.fetch_youtube_playlists_metadata(5)
      ...> 0 < (playlists |> Enum.count())
      true

  """
  def fetch_youtube_playlists_metadata(fetcher) do
    {:ok, playlists_metadata} =
      fetcher.auth |> YouTubeClient.get_user_playlists_information("mine")

    playlists_metadata
  end

  def fetch_youtube_playlist_records(fetcher, max_results) do
    {:ok, playlists_metadata} =
      fetcher.auth |> YouTubeClient.get_user_playlists_information("mine")

    for metadata <- playlists_metadata do
      {metadata, fetcher |> fetch_video_records(metadata["id"], max_results)}
    end
  end

  @doc ~S"""
  fetches videos given a yt playlist id
  ## Examples

      iex> playlist_items = YoutubePlaylistFetcher.fetch_video_records(
      ...>  "PLPfZNpFCEKxk55ry3l3OsPEoiOXumCNKU", 5)
      ...> 0 < playlist_items |> Enum.count()
      true
  """
  def fetch_video_records(fetcher, playlist_id, max_results) do
    playlist_items = fetcher.auth |> YouTubeClient.fetch_playlist_items(playlist_id, max_results)
    playlist_items
  end
end
