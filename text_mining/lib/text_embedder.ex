defmodule TextMining.TextEmbedder do

  defstruct [:model, :tokenizer]

  def new(model_name \\ "sentence-transformers/all-MiniLM-L6-v2") do
    {:ok, model} = Bumblebee.load_model({:hf, model_name})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, model_name})
    %TextMining.TextEmbedder{model: model, tokenizer: tokenizer}
  end

  def mean_pooling(model_output, attention_mask) do
    input_mask_expanded = Nx.new_axis(attention_mask, -1)

    model_output
    |> Nx.multiply(input_mask_expanded)
    |> Nx.sum(axes: [1])
    |> Nx.divide(Nx.sum(input_mask_expanded, axes: [1]))
  end

  def get_embeddings(embedder, texts) do
    inputs = Bumblebee.apply_tokenizer(embedder.tokenizer, texts)
    embedding = Axon.predict(embedder.model.model, embedder.model.params, inputs, compiler: EXLA)

    embedding.hidden_state
    |> mean_pooling(inputs["attention_mask"])
  end

  def get_tensor_distances(x, y) do
    normed_x = x |> norm_tensor()
    normed_y = y |> norm_tensor()
    normed_x
    |> Nx.dot(normed_y |> Nx.transpose())
  end

  def norm_tensor(t) do
    {n, _} = t.shape
    norms = t |> Nx.LinAlg.norm(ord: 2, axes: [1]) |> Nx.reshape({n, 1})
    t |> Nx.divide(norms)
  end
end
