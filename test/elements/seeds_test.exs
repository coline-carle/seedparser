defmodule SeedparserElementSeedsTest do
  @moduledoc false

  use ExUnit.Case, async: true
  # doctest Seedparser.Element.Seeds
  alias Seedparser.Element.Seeds

  test "parse participants" do
    seeds = %{quantity: 50}
    assert Seeds.decode("50") == {:ok, seeds}
  end
end
