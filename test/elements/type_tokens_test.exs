defmodule SeedparserElementTypeTokenTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Seedparser.Element.TypeToken
  alias Seedparser.Element.TypeToken

  test "pars tokens" do
    tokens = [:starlight_rose]
    assert TypeToken.decode("ONLY SLR") == {:ok, tokens}
  end
end
