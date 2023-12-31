defmodule YTOrg.RustBindings do
  use Rustler, otp_app: :youtube_organizer

  def save_wordcloud(text, output_path), do: :erlang.nif_error(:nif_not_loaded)

  def save_wordcloud_from_file(input_file_path, output_path),
    do: :erlang.nif_error(:nif_not_loaded)
end
