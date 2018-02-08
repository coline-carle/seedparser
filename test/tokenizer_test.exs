defmodule SeedParserTokenizerTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Tokenizer
  alias SeedParser.Tokenizer

  test "parse garbage" do
    text = "a dab23"
    tokens = []
    assert Tokenizer.decode(text) == tokens
  end

  test "mix type" do
    text = "100 mix"
    tokens = [{:type, :mix}, {:number, 100}]
    assert Tokenizer.decode(text) == tokens
  end

  test "slr type" do
    text = "<50 SLR>"
    tokens = [{:type, :starlight_rose}, {:number, 50}]
    assert Tokenizer.decode(text) == tokens
  end
end
