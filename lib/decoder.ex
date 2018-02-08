defmodule SeedParser.DecodeError do
  @type t :: %__MODULE__{position: integer, data: String.t()}

  defexception [:position, :data]

  def message(%{position: position, data: data}) when position == byte_size(data) do
    "unexpected end of input at position #{position}"
  end

  def message(%{position: position, data: data}) do
    byte = :binary.at(data, position)
    str = <<byte>>

    if String.printable?(str) do
      "unexpected byte at position #{position}: " <> "#{inspect(byte, base: :hex)} ('#{str}')"
    else
      "unexpected byte at position #{position}: " <> "#{inspect(byte, base: :hex)}"
    end
  end
end

defmodule SeedParser.Decoder do
  @moduledoc false

  alias SeedParser.DecodeError
  alias SeedParser.Normalizer

  # We use integers instead of atoms to take advantage of the jump table
  # optimization
  @title 0
  @key 1
  @value 2

  def decode(data) do
    lines = data |> String.split("\n")
  end
end
