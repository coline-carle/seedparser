defmodule SeedparserElementParticipantsTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest Seedparser.Element.Participants
  alias Seedparser.Element.Participants

  test "parse participants" do
    participants = %{max: 10, count: 2}
    assert Participants.decode("2/10") == {:ok, participants}
  end
end
