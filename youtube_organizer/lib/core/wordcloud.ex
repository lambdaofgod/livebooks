defmodule YTOrg.WordCloud do
  def get_wordcloud_image(text, used_stopwords \\ "en") do
    out_path =
      text
      |> remove_stopwords(used_stopwords |> get_stopwords())
      |> get_saved_wc_path()

    wordcloud_image = File.read!(out_path)
    File.rm!(out_path)
    wordcloud_image
  end

  def get_wordcloud_image_from_text_file(input_file_path, used_stopwords \\ "en") do
    file_content = File.read!(input_file_path)
    get_wordcloud_image(file_content, used_stopwords)
  end

  defp get_saved_wc_path(text) do
    uid = UUID.uuid4()
    out_path = "/tmp/#{uid}_wc.png"
    YTOrg.RustBindings.save_wordcloud(text, out_path)
    out_path
  end

  defp remove_stopwords(text, stopwords) do
    text
    |> String.downcase()
    |> String.split()
    |> Enum.reject(fn word -> word in stopwords end)
    |> Enum.join(" ")
  end

  defp get_stopwords("en") do
    en_stopwords_path =
      "https://gist.githubusercontent.com/sebleier/554280/raw/7e0e4a1ce04c2bb7bd41089c9821dbcf6d0c786c/NLTK's%2520list%2520of%2520english%2520stopwords"

    %_{body: stopwords_contents} = HTTPoison.get!(en_stopwords_path)
    stopwords_contents |> String.split("\n")
  end

  defp get_stopword(stopwords_list) when is_list(stopwords_list) do
    stopwords_list
  end

  defp get_stopwords(stopwords_fn) do
    stopwords_fn.()
  end
end
