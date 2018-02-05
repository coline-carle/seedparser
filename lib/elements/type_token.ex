defmodule SeedParser.Element.TypeToken do
  @moduledoc false
  require Logger

  alias SeedParser.DecodeError

  @text 1

  @spaces '\s\t,.&/'
  @tokens %{
    "slr" => :starlight_rose,
    "foxflower" => :foxflower,
    "ff" => :foxflower,
    "fox" => :foxflower,
    "mix" => :mix,
    "mixed" => :mix
  }

  def decode(data) do
    try do
      node(data, data, 0, [])
    catch
      {:position, position} ->
        {:error, %DecodeError{position: position, data: data}}
    else
      value ->
        {:ok,
         value
         |> Enum.reject(fn value -> value == :unknown end)}
    end
  end

  defp node(<<byte, rest::bits>>, original, skip, stack) when byte in @spaces do
    node(rest, original, skip + 1, stack)
  end

  defp node(<<_, rest::bits>>, original, skip, stack) do
    text(rest, original, skip, [@text | stack], 1)
  end

  defp node(<<>>, _original, _skip, stack) do
    stack
  end

  defp text(<<byte, rest::bits>>, original, skip, stack, len) when byte in @spaces do
    value =
      original
      |> binary_part(skip, len)

    continue(rest, original, skip + len + 1, stack, value)
  end

  defp text(<<_, rest::bits>>, original, skip, stack, len) do
    text(rest, original, skip, stack, len + 1)
  end

  defp text(<<>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)

    continue(<<>>, original, skip + len, stack, value)
  end

  defp tokenize(node) when is_binary(node) do
    value = node |> String.downcase()

    @tokens |> Map.get(value, :unknown)
  end

  defp text_value(rest, original, skip, stack, value) do
    token = tokenize(value)
    stack = [token | stack]
    node(rest, original, skip, stack)
  end

  defp continue(rest, original, skip, stack, value) do
    case stack do
      [@text | stack] ->
        text_value(rest, original, skip, stack, value)
    end
  end
end
