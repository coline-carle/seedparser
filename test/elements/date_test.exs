defmodule SeedparserElementDateTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Seedparser.Element.Date
  alias Seedparser.Element.Date

  test "parse date" do
    date = %{:weekday => :monday, :month => 1, :day => 1}
    assert Date.decode("Monday, January 1st") == {:ok, date}
  end

  test "parse numeral date" do
    date = %{:weekday => :monday, :month => 1, :day => 22, :year => 18}
    assert Date.decode("Monday 22/01/18") == {:ok, date}
  end
end
