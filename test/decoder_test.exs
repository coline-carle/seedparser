defmodule SeedParserDecoderTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Decoder
  alias SeedParser.Decoder

  test "thalipedes template" do
    {:ok, text} = File.read("./test/fixtures/thalipedes.md")

    metadata = %SeedParser{
      date: ~D[2018-01-01],
      time: ~T[22:00:00],
      type: :mix,
      seeds: 60
    }

    today = ~D[2018-01-01]

    assert Decoder.decode(text, today: today) == {:ok, metadata}
  end

  test "format" do
    text = "text ```md text again ```"
    output = "text\n```md\ntext again\n```\n"
    assert Decoder.format(text) == output

    text = "```md text ``````md text again ```"
    output = "\n```md\ntext\n```\n\n```md\ntext again\n```\n"
    assert Decoder.format(text) == output
  end

  test "sholenar template" do
    {:ok, text} = File.read("./test/fixtures/sholenar.md")

    metadata = %SeedParser{
      date: ~D[2018-01-22],
      time: ~T[21:00:00],
      seeds: 100,
      type: :mix
    }

    today = ~D[2018-01-01]

    assert Decoder.decode(text, today: today) == {:ok, metadata}
  end

  test "sholenar template (us version)" do
    {:ok, text} = File.read("./test/fixtures/us_date.md")

    metadata = %SeedParser{
      date: ~D[2018-01-22],
      time: ~T[21:00:00],
      seeds: 100,
      type: :mix
    }

    today = ~D[2018-01-01]

    assert Decoder.decode(text, today: today, date: :us) == {:ok, metadata}
  end

  test "event string us" do
    text = "[30 FF] [2300 EST Sun, 2/11/18] ***This is 3/3 raids back to back.***"

    metadata = %SeedParser{
      date: ~D[2018-02-11],
      time: ~T[23:00:00],
      seeds: 30,
      type: :foxflower
    }

    today = ~D[2018-02-11]

    assert Decoder.decode(text, today: today, date: :us) == {:ok, metadata}
  end

  test "upcomming event error" do
    text = "```ini [List of upcoming raids] [Read each individual raid post before signing up]```"

    assert Decoder.decode(text) == {:error, :upcoming}
  end

  test "us date and time" do
    text = "[200 Mixed] [No FF]\n[19:00 EST  Sun Feb 11]"

    metadata = %SeedParser{
      date: ~D[2018-02-11],
      time: ~T[19:00:00],
      seeds: 200,
      type: :mix
    }

    today = ~D[2018-02-11]
    assert Decoder.decode(text, today: today, date: :us) == {:ok, metadata}
  end

  test "point dates" do
    text = "ini [100 SLR Raid]``````fix • Date: 13.02.2018. • Time: 19:00 CET • "

    metadata = %SeedParser{
      date: ~D[2018-02-13],
      time: ~T[19:00:00],
      seeds: 100,
      type: :starlight_rose
    }

    today = ~D[2018-02-11]
    assert Decoder.decode(text, today: today, date: :eu) == {:ok, metadata}
  end

  test "two types" do
    text = "[200 Mixed] [100 fox][No FF]\n[19:00 EST  Sun Feb 11]"

    metadata = %SeedParser{
      date: ~D[2018-02-11],
      time: ~T[19:00:00],
      seeds: 200,
      type: :mix
    }

    today = ~D[2018-02-11]
    assert Decoder.decode(text, today: today, date: :us) == {:ok, metadata}
  end
end
