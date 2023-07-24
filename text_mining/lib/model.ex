defmodule TextMining.ComparisonResult do
  defstruct [:compared_document, :matched_documents, :scores]
end

defmodule TextMining.Document do
  @enforce_keys [:text]
  defstruct [:text, :metadata]
end
