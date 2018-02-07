defmodule SeedParserElementDateTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Element.Date
  alias SeedParser.Element.Date

  test "parse date" do
    now = DateTime.utc_now()
    date = {now.year, 1, 1}
    assert Date.decode("Monday, January 1st") == {:ok, date}
  end

  test "parse numeral date" do
    date = {2018, 1, 22}
    assert Date.decode("Monday 22/01/18") == {:ok, date}
  end
end
