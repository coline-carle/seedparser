defmodule SeedParserElementRequiredTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest SeedParser.Element.Required
  alias SeedParser.Element.Required

  test "parse participants" do
    required = %{:aethril => 3, :felwort => 3}
    assert Required.decode("AT 3 & FW 3") == {:ok, required}
  end
end
