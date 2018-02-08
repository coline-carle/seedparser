defmodule SeedParser.Decoder do
  @moduledoc false

  alias SeedParser.Tokenizer

  def decode(data) do
    data
    |> String.split("\n")
    |> decode_line([])
  end

  defp decode_line([], stack), do: stack

  defp decode_line([line | lines], stack) do
    stack =
      line
      |> Tokenizer.decode()
      |> decode_tokens(stack)

    decode_line(lines, stack)
  end

  defp decode_tokens([], stack), do: stack

  defp decode_tokens([{:type, type}, {:number, seeds} | tokens], stack) do
    stack = [{:type, type}, {seeds, :seeds} | stack]
    decode_tokens(tokens, stack)
  end

  defp decode_tokens([_any | tokens], stack) do
    decode_tokens(tokens, stack)
  end
end
