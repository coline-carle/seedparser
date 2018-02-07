defmodule SeedParserElementTitleTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Element.Title
  alias SeedParser.Element.Title

  test "parse title" do
    assert Title.decode("dddd 50 SLR") == {:ok, {:starlight_rose, 50}}
  end
end
