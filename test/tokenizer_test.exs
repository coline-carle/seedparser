defmodule SeedParserTokenizerTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Tokenizer
  alias SeedParser.Tokenizer

  test "parse garbage" do
    text = "a dab23"
    tokens = [{:text, "dab23"}, {:text, "a"}]
    assert Tokenizer.decode(text) == tokens
  end

  test "parse valid user" do
    text = "<@123>"
    tokens = [{:user, 123}]
    assert Tokenizer.decode(text) == tokens
  end

  test "parse valid nick user" do
    text = "<@!123>"
    tokens = [{:user, 123}]
    assert Tokenizer.decode(text) == tokens
  end

  test "backup test" do
    text = "Stand by:  <@355118113748156416>"
    tokens = [{:user, 355_118_113_748_156_416}, {:punct, ":"}, {:token, :by}, {:token, :stand}]
    assert Tokenizer.decode(text) == tokens
  end

  test "parse valid nick followed by number" do
    text = "<@!123> 42"
    tokens = [{:number, 42}, {:user, 123}]
    assert Tokenizer.decode(text) == tokens
  end

  test "parse garbage user" do
    text = "<@!123a 1"
    tokens = [{:number, 1}, {:text, "a"}]
    assert Tokenizer.decode(text) == tokens
  end

  test "mix type" do
    text = "100 mix"
    tokens = [{:type, :mix}, {:number, 100}]
    assert Tokenizer.decode(text) == tokens
  end

  test "30 foxflower" do
    text = "```ini [30 Foxflower]``````markdown"
    tokens = [{:text, "``````markdown"}, {:type, :foxflower}, {:number, 30}, {:text, "```ini"}]
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

    tokens = [
      {:text, "th"},
      {:number, 08},
      {:month, 02},
      {:punct, ","},
      {:weekday, 3},
      {:punct, ":"},
      {:text, "DATE"}
    ]

    assert Tokenizer.decode(text) == tokens

    text = "[[DATE:](Monday, January 1st)"

    tokens = [
      {:text, "st"},
      {:number, 01},
      {:month, 01},
      {:punct, ","},
      {:weekday, 0},
      {:punct, ":"},
      {:text, "DATE"}
    ]

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
      {:punct, ":"},
      {:text, "DATE"}
    ]

    assert Tokenizer.decode(text) == tokens
  end

  test "upcomming" do
    text = "[List of upcoming raids]"

    tokens = [
      {:token, :events},
      {:token, :upcoming},
      {:text, "of"},
      {:text, "List"}
    ]

    assert Tokenizer.decode(text) == tokens
  end

  test "upcomming 2" do
    text = "***UPCOMING EVENTS!***"

    tokens = [
      {:token, :events},
      {:token, :upcoming}
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
      {:punct, ":"},
      {:text, "DATE"}
    ]

    assert Tokenizer.decode(text) == tokens
  end
end
