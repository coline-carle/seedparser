defmodule SeedParserDecoderTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Decoder
  alias SeedParser.Decoder

  test "thalipedes template" do
    {:ok, text} = File.read("./test/fixtures/thalipedes.md")

    informations = %SeedParser{
      date: ~D[2018-01-01],
      time: ~T[22:00:00],
      type: :mix,
      seeds: 60,
      content: text
    }

    today = ~D[2018-01-01]

    assert Decoder.decode(text, today) == {:ok, informations}
  end

  test "sholenar template" do
    {:ok, text} = File.read("./test/fixtures/sholenar.md")

    informations = %SeedParser{
      date: ~D[2018-01-22],
      time: ~T[21:00:00],
      seeds: 100,
      type: :mix,
      content: text
    }

    today = ~D[2018-01-01]

    assert Decoder.decode(text, today) == {:ok, informations}
  end
end
