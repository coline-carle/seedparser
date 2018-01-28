defmodule SeedparserElementMaxTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Seedparser.Element.Max
  alias Seedparser.Element.Max

  test "parse participants" do
    max = %{:aethril => 15}
    assert Max.decode("15 AT") == {:ok, max}
  end
end
