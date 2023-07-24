defmodule TextMining.EmbeddingClusterer do
  alias TextMining.{Utils, TextEmbedder}
  alias Scholar.Cluster.KMeans
  defstruct [:text_embedder, :model]

  def new(text_embedder) do
    %TextMining.EmbeddingClusterer{text_embedder: text_embedder}
  end

  def fit_clustering(clusterer, documents, n_clusters) do
    texts = documents |> Enum.map(fn document -> document.text end)
    embeddings = clusterer.text_embedder |> TextEmbedder.get_embeddings(texts)
    model = clusterer |> fit_clustering_model(embeddings, n_clusters)

    labels = model.labels |> Nx.to_list()
    %TextMining.EmbeddingClusterer{text_embedder: clusterer.text_embedder, model: model}
  end

  def get_clustered_documents(clusterer, documents) do
    texts = documents |> Enum.map(& &1.text)
    embeddings = clusterer.text_embedder |> TextEmbedder.get_embeddings(texts)
    labels = clusterer.model |> KMeans.predict(embeddings) |> Nx.to_list()
    documents |> Utils.group_by_labels(labels)
  end

  def get_closest_cluster(clusterer, document) do
    document_embedding = clusterer.text_embedder |> TextEmbedder.get_embeddings([document.text])

    cluster_distances =
      document_embedding |> TextEmbedder.get_tensor_distances(clusterer.model.clusters)

    cluster_distances |> Nx.argmax() |> Nx.to_number()
  end

  defp fit_clustering_model(_clusterer, embeddings, n_clusters) do
    embeddings |> KMeans.fit(num_clusters: n_clusters)
  end
end
