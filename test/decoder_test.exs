defmodule SeedParserDecoderTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Decoder
  alias SeedParser.Decoder

  test "parse title" do
    # informations = %{:title => "title"}
    # assert Decoder.decode("<title>", transform: false) == {:ok, informations}
    # assert Decoder.decode("[title]", tranform: false) == {:ok, informations}
    # assert Decoder.decode("  [title]", transform: false) == {:ok, informations}
  end

  test "parse keyvalues" do
    informations = %{"key" => "value"}
    tokens = %{}

    assert Decoder.decode("<title>\n[key](value)", transform: false) ==
             {:ok, {informations, tokens}}

    assert Decoder.decode("```md\n<title>\n--\n* [key](value)", transform: false) ==
             {:ok, {informations, tokens}}
  end

  test "normalize keys" do
    informations = %{:seeds => 600}
    tokens = %{}

    assert Decoder.decode("<title>\n[SEEDS:](600)", transform: false) ==
             {:ok, {informations, tokens}}
  end

  test "thalipedes template" do
    {:ok, text} = File.read("./test/fixtures/thalipedes.md")

    informations = %{
      date: %{day: 1, month: 1, weekday: :monday},
      time: %{hour: 22, minute: 0},
      seeds: 60
    }

    tokens = %{}

    assert Decoder.decode(text, transform: false) == {:ok, {informations, tokens}}
  end

  test "sholenar template" do
    {:ok, text} = File.read("./test/fixtures/sholenar.md")

    informations = %{
      :title => "100 Mixed",
      :title_tokens => [:mix],
      :date => %{day: 22, month: 1, weekday: :monday, year: 18},
      :time => %{hour: 21, minute: 0},
      :required => %{aethril: 3, felwort: 3},
      :max => %{foxflower: 0, felwort: 0, any: 50},
      :seeds => %{quantity: 100},
      :participants => %{count: 10, max: 10}
    }

    tokens = %{
      title: [:mix]
    }

    assert Decoder.decode(text, transform: false) == {:ok, {informations, tokens}}
  end
end
