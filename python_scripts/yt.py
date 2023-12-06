import scrapetube
import itertools
import fire
import json
from concurrent.futures import ProcessPoolExecutor


def get_videos(channel_url, n_videos=10):
    channel_videos_generator = scrapetube.get_channel(
        channel_url=channel_url, limit=n_videos)
    channel_videos_list = list(channel_videos_generator)
    dates = _get_videos_dates(channel_videos_list)
    for vid in channel_videos_list:
        vid["dateText"] = dates[vid["videoId"]]
    return json.dumps(channel_videos_list)


def _get_videos_dates(videos):
    return dict(ProcessPoolExecutor().map(_get_video_date, videos))


def _get_video_date(vid):
    video_id = vid["videoId"]
    return (video_id, scrapetube.scrapetube.get_video(vid["videoId"])["dateText"])


if __name__ == "__main__":
    fire.Fire(get_videos)
