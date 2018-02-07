defmodule SeedParserElementTimeTest do
  @moduledoc false

  use ExUnit.Case, async: true
  # doctest SeedParser.Element.Seeds
  alias SeedParser.Element.Time

  test "parse time" do
    time = {22, 00, 00}
    assert Time.decode("22:00 Server Time") == {:ok, time}
  end
end
