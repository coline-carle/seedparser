defmodule SeedParserElementTypeTokenTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Element.TypeToken
  alias SeedParser.Element.TypeToken

  test "parse tokens" do
    tokens = [:starlight_rose]
    assert TypeToken.decode("ONLY SLR") == {:ok, tokens}
  end
end
