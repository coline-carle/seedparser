defmodule SeedParser.Element.Style do
  @moduledoc false

  alias SeedParser.Normalizer

  @values %{
    "2-Phase" => :two_phase
  }

  def decode(data) do
    {:ok,
     data
     |> Normalizer.normalize(@values)}
  end
end
