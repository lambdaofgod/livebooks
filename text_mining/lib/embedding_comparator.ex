defmodule TextMining.EmbeddingComparator do
  alias TextMining.TextEmbedder

  defstruct [:text_embedder]

  def new(model_name \\ "sentence-transformers/all-MiniLM-L6-v2") do
    embedder = TextMining.TextEmbedder.new(model_name)
    %TextMining.EmbeddingComparator{text_embedder: embedder}
  end
end

defimpl TextMining.DocumentCreator, for: TextMining.EmbeddingComparator do
  alias TextMining.Document
  @spec make_document(any(), String.t() | Map.t(), String.t()) :: Document.t()
  def make_document(document_creator, text, document_id) when is_bitstring(text) do
    document_creator |> make_document(%{"text" => text}, document_id)
  end

  def make_document(_document_creator, %{"text" => text} = record, document_id) do
    id =
      cond do
        document_id == nil -> text
        true -> document_id
      end

    document_record = Map.delete(record, "text")
    %Document{text: text, id: id, metadata: document_record}
  end

  def make_document(document_creator, raw_doc) do
    document_creator |> make_document(raw_doc, nil)
  end

  defp get_id(%{"id" => id}), do: id
  defp get_id(%{"name" => name}), do: name
  defp get_id(_), do: nil
end

defimpl TextMining.TextComparator, for: TextMining.EmbeddingComparator do
  alias TextMining.{Document, ComparisonResult, TextEmbedder, DocumentCreator}

  def compare_documents(comparator, reference_list, compared_list, n_closest \\ 1) do
    distances = comparator |> get_distances(reference_list, compared_list)

    get_comparison_results(
      reference_list,
      compared_list,
      distances,
      n_closest
    )
  end

  def compare_texts(comparator, reference_texts, compared_texts, n_closest) do
    make_doc = fn text -> DocumentCreator.make_document(comparator, text, nil) end
    reference_documents = Enum.map(reference_texts, make_doc)
    compared_documents = Enum.map(compared_texts, make_doc)
    comparator |> compare_documents(reference_documents, compared_documents, n_closest)
  end

  def embed(comparator, documents) do
    texts =
      for rec <- documents do
        rec.text
      end

    comparator.text_embedder |> TextEmbedder.get_embeddings(texts)
  end

  defp get_distances(comparator, reference_list, compared_list) do
    reference_embeddings = comparator |> embed(reference_list)
    compared_embedings = comparator |> embed(compared_list)
    reference_embeddings |> TextEmbedder.get_tensor_distances(compared_embedings)
  end

  defp get_comparison_results(reference_documents, compared_documents, distances, n_closest \\ 1) do
    all_indices = distances |> TextEmbedder.get_indices_from_distances()

    {n_reference, _} = all_indices.shape

    indices =
      all_indices
      |> Nx.slice([0, 0], [n_reference, n_closest])
      |> Nx.to_list()

    for {match_indices, row_idx} <- Enum.with_index(indices), into: %{} do
      doc = Enum.at(reference_documents, row_idx)

      doc
      |> get_comparison_result(
        row_idx,
        compared_documents,
        match_indices,
        distances
      )
    end
  end

  defp get_comparison_result(
         document,
         row_idx,
         matched_documents,
         match_indices,
         distances
       ) do
    matched_documents =
      for i <- match_indices do
        Enum.at(matched_documents, i)
      end

    scores =
      for i <- match_indices do
        Nx.to_number(distances[[row_idx, i]])
      end

    matched_result = %{
      "matched_documents" => matched_documents,
      "scores" => scores,
      "document" => document
    }

    {document.id, matched_result}
  end
end
