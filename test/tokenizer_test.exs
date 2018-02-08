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

  test "final point" do
    text = "Jan. 23"
    tokens = [{:number, 23}, {:month, 1}]
    assert Tokenizer.decode(text) == tokens
  end

  test "slr type" do
    text = "<50 SLR>"
    tokens = [{:type, :starlight_rose}, {:number, 50}]
    assert Tokenizer.decode(text) == tokens
  end

  test "date-eu-alliance-2" do
    text = "[DATE:](Thursday, Feb 8th)"
    tokens = [{:number, 08}, {:month, 02}, {:punct, ","}, {:weekday, 3}, {:punct, ":"}]
    assert Tokenizer.decode(text) == tokens

    text = "[[DATE:](Monday, January 1st)"
    tokens = [{:number, 01}, {:month, 01}, {:punct, ","}, {:weekday, 0}, {:punct, ":"}]
    assert Tokenizer.decode(text) == tokens
  end

  test "date-eu-alliance-1" do
    text = "DATE: Thursday, 08.02"

    tokens = [
      {:number, 02},
      {:punct, "."},
      {:number, 08},
      {:punct, ","},
      {:weekday, 3},
      {:punct, ":"}
    ]

    assert Tokenizer.decode(text) == tokens
  end

  test "date-eu-aliance-3" do
    text = "[DATE:](Monday 22/01/18)"

    tokens = [
      {:number, 18},
      {:punct, "/"},
      {:number, 01},
      {:punct, "/"},
      {:number, 22},
      {:weekday, 0},
      {:punct, ":"}
    ]

    assert Tokenizer.decode(text) == tokens
  end
end
