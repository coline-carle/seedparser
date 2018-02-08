defmodule SeedParserDecoderTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Decoder
  alias SeedParser.Decoder

  test "thalipedes template" do
    {:ok, text} = File.read("./test/fixtures/thalipedes.md")

    informations = %{
      date: ~D[2018-01-01],
      time: {22, 0, 0},
      type: :mix,
      seeds: 60
    }

    today = ~D[2018-01-01]

    assert Decoder.decode(text, today) == {:ok, informations}
  end

  test "sholenar template" do
    {:ok, text} = File.read("./test/fixtures/sholenar.md")

    informations = %{
      date: ~D[2018-01-22],
      time: {21, 0, 0},
      seeds: 100,
      type: :mix
    }

    today = ~D[2018-01-01]

    assert Decoder.decode(text, today) == {:ok, informations}
  end
end
