defmodule SeedParserElementSeedsTest do
  @moduledoc false

  use ExUnit.Case, async: true
  # doctest SeedParser.Element.Seeds
  alias SeedParser.Element.Seeds

  test "parse participants" do
    seeds = 50
    assert Seeds.decode("50") == {:ok, seeds}
  end
end
