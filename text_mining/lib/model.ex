defmodule TextMining.Document do
  @enforce_keys [:text]
  defstruct [:text, :id, :metadata]
end
