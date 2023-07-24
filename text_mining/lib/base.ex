defprotocol TextMining.TextComparator do
  alias TextMining.Document
  @moduledoc """
  Comparing texts using embeddings.

  Embeddings are extracted with TextEmbedder that uses Huggingface transformers.
  """
  @doc """
  Compare two lists of text documents.
  """
  @spec compare_documents(
          any(),
          [Document.t()],
          [Document.t()],
          Integer.t()
        ) :: [Map.t()]
  def compare_documents(comparator, reference_documents, compared_documents, n_closest)

  @spec embed(any(), [Document.t()]) :: Nx.Tensor
  def embed(comparator, documents)
end

defprotocol TextMining.DocumentCreator do
  alias TextMining.Document
  @spec make_document(any(), String.t() | Map.t(), String.t()) :: Document.t()
  def make_document(document_creator, raw_document, document_id)

  @spec make_document(any(), String.t() | Map.t()) :: Document.t()
  def make_document(document_creator, raw_document)
end

defprotocol TextMining.TextClusterer do
  #@spec get_clustering_result(any(), [Document.t()], Integer.t) :: Map.t()
  def get_clustering(clusterer, documents, n_clusters)
end
