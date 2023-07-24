defmodule YTOrg.YouTubeClient do
  @moduledoc """
  A simple YouTube client.
  """
  require Poison
  require HTTPoison

  @youtube_api_url "https://www.googleapis.com"

  def fetch_playlist_items(auth_wrapper, playlist_id, max_results) do
    url = "#{@youtube_api_url}/youtube/v3/playlistItems?part=snippet&playlistId=#{playlist_id}&maxResults=#{max_results}"
    headers = [{"Authorization", "Bearer #{auth_wrapper.token}"}]
    {:ok, %{status_code: 200, body: body}} = HTTPoison.get(url, headers)

    case Poison.decode(body) do
      {:ok, response} ->
        response["items"]

      # |> Enum.map(&(&1["snippet"]["title"]))

      {:error, error} ->
        IO.puts("Failed to decode JSON: #{error}")
        :error
    end
  end

  def get_user_playlists_information(auth_wrapper, user_id) do
    auth_wrapper
    |> call_list_user_playlist(user_id)
    |> parse_user_result_body()
  end

  defp parse_user_result_body({:ok, body}) do
    youtube_playlists =
      body
      |> Poison.decode!()

    youtube_playlists |> inspect() |> IO.puts()
    # yp_body = youtube_playlists |> Map.get("pageInfo")
    # yp_body |> inspect() |> IO.puts()
    yp_body =
      youtube_playlists
      |> Map.get("items")

    {:ok, yp_body}
  end

  defp parse_user_result_body(result = {:error, _}) do
    result
  end

  defp call_list_user_playlist(auth_wrapper, user_id) do
    url_part =
      cond do
        user_id == "mine" -> "mine=true"
        true -> "channelId=#{user_id}"
      end

    headers = [{"Authorization", "Bearer #{auth_wrapper.token}"}]
    url = "#{@youtube_api_url}/youtube/v3/playlists?part=snippet&#{url_part}&maxResults=50"
    {:ok, response} = HTTPoison.get(url, headers)
    %{status_code: 200, body: body} = response
    {:ok, body}
  end
end
