defmodule SeedParserDecoderTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Decoder
  alias SeedParser.Decoder

  test "thalipedes template" do
    {:ok, text} = File.read("./test/fixtures/thalipedes.md")

    informations = %{
      date: {2018, 1, 1},
      time: {22, 0, 0}
    }

    assert Decoder.decode(text) == {:ok, informations}
  end

  test "sholenar template" do
    {:ok, text} = File.read("./test/fixtures/sholenar.md")

    informations = %{
      date: {2018, 1, 22},
      time: {21, 0, 0},
      size: 100,
      type: :mix
    }

    assert Decoder.decode(text) == {:ok, informations}
  end
end
