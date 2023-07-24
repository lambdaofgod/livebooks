defmodule TextMining.EmbeddingComparatorBehaviour do
  alias TextMining.{Document, ComparisonResult}

  @callback compare_documents(any(), [Document.t()], [Document.t()], Integer.t()) :: [
              ComparisonResult.t()
            ]

  @callback make_document(Map.t()) :: Document.t()

  @callback embed(any(), [Document.t()]) :: Nx.Tensor
end

defmodule TextMining.EmbeddingComparator do
  alias TextMining.{Document, ComparisonResult}

  @callback compare_documents(any(), [Document.t()], [Document.t()], Integer.t()) :: [
              ComparisonResult.t()
            ]

  @callback make_document(Map.t()) :: Document.t()

  @callback embed(any(), [Document.t()]) :: Nx.Tensor

  alias TextMining.{Document, TextEmbedder, EmbeddingComparator}

  defstruct [:text_embedder]

  def new(model_name \\ "sentence-transformers/all-MiniLM-L6-v2") do
    embedder = TextMining.TextEmbedder.new(model_name)
    %TextMining.EmbeddingComparator{text_embedder: embedder}
  end

  @behaviour TextMining.EmbeddingComparator

  @impl
  def compare_records(comparator, reference_list, compared_list, n_closest \\ 1) do
    distances = comparator |> get_distances(reference_list, compared_list)

    get_comparison_results(
      reference_list,
      compared_list,
      distances,
      n_closest
    )
  end

  @impl
  def make_document(text) do
    %Document{text: text}
  end

  @impl
  def embed(comparator, records) do
    texts =
      for rec <- records do
        rec.text
      end

    comparator.text_embedder |> TextEmbedder.get_embeddings(texts)
  end

  defp get_distances(comparator, reference_list, compared_list) do
    reference_embeddings = comparator |> embed(reference_list)
    compared_embedings = comparator |> embed(compared_list)
    reference_embeddings |> TextEmbedder.get_tensor_distances(compared_embedings)
  end

  defp get_indices_from_distances(distances) do
    distances |> Nx.argsort(direction: :desc)
  end

  defp get_comparison_results(reference_documents, compared_documents, distances, n_closest \\ 1) do
    all_indices = distances |> get_indices_from_distances()

    {n_reference, _} = all_indices.shape

    indices =
      all_indices
      |> Nx.slice([0, 0], [n_reference, n_closest])
      |> Nx.to_list()

    for {match_indices, row_idx} <- Enum.with_index(indices) do
      text = Enum.at(reference_documents, row_idx)

      get_comparison_result(
        text,
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

    %ComparisonResult{
      compared_document: document,
      matched_documents: matched_documents,
      scores: scores
    }
  end
end
