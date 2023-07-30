defmodule TextMining.Document do
  @moduledoc """
  Public APIs of TextMining will operate on this struct
  """

  @enforce_keys [:text]
  defstruct [:text, :id, :metadata]
end
