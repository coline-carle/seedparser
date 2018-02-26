defmodule SeedParserDecoderTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Decoder
  alias SeedParser.Decoder

  test "upcoming raids file" do
    {:ok, text} = File.read("./test/fixtures/upcoming_raids.md")
    today = ~D[2018-02-20]

    assert Decoder.decode(text, today: today) == {:error, :upcoming}
  end

  test "upcoming events" do
    text = "**_Upcoming raids!_**"

    today = ~D[2018-02-20]

    assert Decoder.decode(text, today: today) == {:error, :upcoming}
  end

  test "pm date" do
    text = "<200 mixed seed raid> <Thursday, March 1st> <10pm EST>"

    metadata = %SeedParser{
      date: ~D[2018-03-01],
      time: ~T[22:00:00],
      type: :mix,
      seeds: 200,
      participants: nil,
      roster: [],
      backup: []
    }

    today = ~D[2018-02-20]

    assert Decoder.decode(text, today: today) == {:ok, metadata}
  end

  test "100mix" do
    {:ok, text} = File.read("./test/fixtures/100mix.md")

    metadata = %SeedParser{
      date: ~D[2018-03-02],
      time: ~T[22:00:00],
      type: :mix,
      seeds: 100,
      participants: nil,
      roster: [],
      backup: []
    }

    today = ~D[2018-02-20]

    assert Decoder.decode(text, today: today) == {:ok, metadata}
  end

  test "417401865958064138" do
    {:ok, text} = File.read("./test/fixtures/417401865958064138.md")

    metadata = %SeedParser{
      date: ~D[2018-02-26],
      time: ~T[20:00:00],
      type: :mix,
      seeds: 100,
      participants: nil,
      roster: [],
      backup: []
    }

    today = ~D[2018-02-20]

    assert Decoder.decode(text, today: today) == {:ok, metadata}
  end

  test "template with channel" do
    {:ok, text} = File.read("./test/fixtures/template_with_channel.md")

    metadata = %SeedParser{
      date: ~D[2018-02-20],
      time: ~T[01:30:00],
      type: :mix,
      seeds: 100,
      participants: nil,
      roster: [
        113_009_099_544_760_320,
        143_129_714_939_133_952,
        168_225_928_269_266_945,
        188_165_004_283_871_232,
        217_397_918_045_306_880,
        247_516_165_612_503_040,
        302_264_833_464_860_682,
        303_693_556_093_288_459
      ],
      backup: [355_118_113_748_156_416]
    }

    today = ~D[2018-02-20]
    assert Decoder.decode(text, today: today) == {:ok, metadata}
  end

  test "thalipedes template" do
    {:ok, text} = File.read("./test/fixtures/thalipedes.md")

    metadata = %SeedParser{
      date: ~D[2018-01-01],
      time: ~T[22:00:00],
      type: :mix,
      seeds: 60,
      participants: 6,
      roster: [],
      backup: []
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

  test "without backup" do
    {:ok, text} = File.read("./test/fixtures/without_backup.md")

    metadata = %SeedParser{
      date: ~D[2018-02-23],
      time: ~T[21:00:00],
      seeds: 100,
      type: :starlight_rose,
      roster: [
        169_944_372_391_968_768,
        176_764_824_980_553_729,
        184_404_633_836_322_817,
        209_515_182_890_811_392,
        216_922_367_899_729_921,
        221_339_571_223_396_352,
        225_316_622_653_587_467,
        341_591_377_655_758_868,
        387_282_925_248_577_537,
        392_418_877_918_937_100
      ],
      backup: [],
      participants: 10
    }

    today = ~D[2018-02-20]

    assert Decoder.decode(text, today: today) == {:ok, metadata}
  end

  test "sholenar template" do
    {:ok, text} = File.read("./test/fixtures/sholenar.md")

    metadata = %SeedParser{
      date: ~D[2018-01-22],
      time: ~T[21:00:00],
      seeds: 100,
      type: :mix,
      roster: [123, 1_234_567],
      backup: [123_456],
      participants: 10
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
      type: :mix,
      roster: [12_345_678],
      backup: [],
      participants: nil
    }

    today = ~D[2018-01-01]

    assert Decoder.decode(text, today: today, date: :na) == {:ok, metadata}
  end

  test "event string us" do
    text = "[30 FF] [2300 EST Sun, 2/11/18] ***This is 3/3 raids back to back.***"

    metadata = %SeedParser{
      date: ~D[2018-02-11],
      time: ~T[23:00:00],
      seeds: 30,
      type: :foxflower,
      roster: [],
      backup: []
    }

    today = ~D[2018-02-11]

    assert Decoder.decode(text, today: today, date: :na) == {:ok, metadata}
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
      type: :mix,
      roster: [],
      backup: []
    }

    today = ~D[2018-02-11]
    assert Decoder.decode(text, today: today, date: :na) == {:ok, metadata}
  end

  test "point dates" do
    text = "ini [100 SLR Raid]``````fix • Date: 13.02.2018. • Time: 19:00 CET • "

    metadata = %SeedParser{
      date: ~D[2018-02-13],
      time: ~T[19:00:00],
      seeds: 100,
      type: :starlight_rose,
      roster: [],
      backup: []
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
      type: :mix,
      roster: [],
      backup: []
    }

    today = ~D[2018-02-11]
    assert Decoder.decode(text, today: today, date: :na) == {:ok, metadata}
  end
end
