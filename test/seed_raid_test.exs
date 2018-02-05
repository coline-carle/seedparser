defmodule SeedParserSeedRaidTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.SeedRaid
  alias SeedParser.SeedRaid

  test "parse mix" do
    informations = %{
      title: "title",
      date: %{day: 22, month: 1, weekday: :monday, year: 18},
      time: %{hour: 21, minute: 0},
      seeds: %{quantity: 100},
      style: :two_phase,
      required: %{felwort: 3, aethril: 3},
      title_tokens: [:mix],
      max: %{foxflower: 0, felwort: 0, any: 50}
    }

    raid = SeedRaid.transform(informations)

    assert raid.title == "title"
    assert raid.datetime == {{2018, 01, 22}, {21, 00, 00}}
    assert raid.type == :mix
    assert raid.size == 100
    assert raid.style == :two_phase
    assert raid.requirements == [aethril: 3, felwort: 3]
    assert raid.max == [any: 50, felwort: 0, foxflower: 0]
    assert raid.participants == 0
  end

  test "parse slr" do
    informations = %{
      title: "title",
      date: %{day: 22, month: 1, weekday: :monday, year: 18},
      time: %{hour: 21, minute: 0},
      seeds: %{quantity: 100},
      style: :two_phase,
      required: %{felwort: 3, aethril: 3},
      participants: %{count: 6, max: 10},
      max_tokens: [:starlight_rose]
    }

    raid = SeedRaid.transform(informations)

    assert raid.title == "title"
    assert raid.datetime == {{2018, 01, 22}, {21, 00, 00}}
    assert raid.type == :starlight_rose
    assert raid.size == 100
    assert raid.style == :two_phase
    assert raid.requirements == [aethril: 3, felwort: 3]
    assert raid.participants == 6
  end
end
