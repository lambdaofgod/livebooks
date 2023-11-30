defmodule YTOrg.YoutubeRecordParser do
  alias YTOrg.{YoutubePlaylist, YoutubePlaylistMetadata, YoutubeVideo}

  def parse_playlist_metadata(record) do
    %{"id" => id, "snippet" => %{"title" => title}} = record
    %YoutubePlaylistMetadata{id: id, title: title}
  end

  def parse_video(record) do
    %{
      "id" => item_id,
      "snippet" => %{
        "title" => title,
        "description" => description,
        "publishedAt" => published_at_raw,
        "channelId" => channel_id,
        "channelTitle" => channel_title
      }
    } = record

    id = get_video_id(record)

    published_at =
      case published_at_raw |> DateTime.from_iso8601() do
        {:ok, dt, _} -> dt
        {:ok, dt} -> dt
        {:error, _} -> nil
      end

    yt_vid = %YoutubeVideo{
      id: id,
      title: title,
      description: description,
      playlist_item_id: item_id,
      url: get_url(id),
      published_at: published_at,
      channel_id: channel_id,
      channel_title: channel_title
    }

    maybe_add_thumbnails(yt_vid, record["snippet"])
  end

  def parse_playlist(metadata_record, video_records) do
    %YoutubePlaylist{
      metadata: metadata_record |> parse_playlist_metadata(),
      videos: video_records |> Enum.map(&parse_video/1)
    }
  end

  defp get_video_id(%{"snippet" => %{"resourceId" => res}}) do
    %{"videoId" => id} = res
    id
  end

  defp get_video_id(%{"id" => %{"videoId" => id}}) do
    id
  end

  defp get_url(id) do
    "https://www.youtube.com/watch?v=#{id}"
  end

  defp maybe_add_thumbnails(yt_vid, %{"thumbnails" => thumbnails}) do
    Map.put(yt_vid, :thumbnails, thumbnails)
  end

  defp maybe_add_thumbnails(yt_vid, _) do
    yt_vid
  end
end
