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

  test "date-eu-alliance-2" do
    text = "[DATE:](Thursday, Feb 8th)"
    tokens = [{:number, 08}, {:month, 02}, {:punct, ","}, {:weekday, 3}]
    assert Tokenizer.decode(text) == tokens
  end

  test "date-eu-alliance-1" do
    text = "DATE: Thursday, 08.02"
    tokens = [{:number, 02}, {:punct, "."}, {:number, 08}, {:punct, ","}, {:weekday, 3}]
    assert Tokenizer.decode(text) == tokens
  end
end
