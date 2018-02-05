defmodule SeedParser.Element.Required do
  @moduledoc false

  @digits '01234556789'
  @spaces '\s\t,.&'
  @rank 0
  @seed 1

  alias SeedParser.DecodeError
  alias SeedParser.Normalizer
  require Logger

  def decode(data) do
    try do
      seed(data, data, 0, [])
    catch
      {:position, position} ->
        {:error, %DecodeError{position: position, data: data}}
    else
      value ->
        {:ok,
         value
         |> Normalizer.normalize()
         |> Enum.into(%{})}
    end
  end

  defp rank(<<byte, rest::bits>>, original, skip, stack) when byte in @digits do
    rank(rest, original, skip, [@rank | stack], 1)
  end

  defp rank(<<_, rest::bits>>, original, skip, stack) do
    rank(rest, original, skip + 1, stack)
  end

  defp rank(<<>>, original, skip, _stack) do
    error(original, skip)
  end

  defp rank(<<byte, rest::bits>>, original, skip, stack, len) when byte in @digits do
    rank(rest, original, skip, stack, len + 1)
  end

  defp rank(<<byte, rest::bits>>, original, skip, stack, len) when byte in @spaces do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(rest, original, skip + len + 1, stack, value)
  end

  defp rank(<<>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(<<>>, original, skip + len, stack, value)
  end

  defp rank(<<_::bits>>, original, skip, _stack, len) do
    error(original, skip + len)
  end

  defp seed(<<byte, rest::bits>>, original, skip, stack) when byte in @spaces do
    seed(rest, original, skip + 1, stack)
  end

  defp seed(<<_, rest::bits>>, original, skip, stack) do
    seed(rest, original, skip, [@seed | stack], 1)
  end

  defp seed(<<>>, _original, _skip, stack) do
    stack
  end

  defp seed(<<byte, rest::bits>>, original, skip, stack, len) when byte in @spaces do
    value =
      original
      |> binary_part(skip, len)

    continue(rest, original, skip + len + 1, stack, value)
  end

  defp seed(<<_, rest::bits>>, original, skip, stack, len) do
    seed(rest, original, skip, stack, len + 1)
  end

  defp seed(<<>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)

    continue(<<>>, original, skip + len, stack, value)
  end

  defp rank_value(rest, original, skip, stack, value) do
    [{:seed, seed} | stack] = stack
    stack = [{seed, value} | stack]
    seed(rest, original, skip, stack)
  end

  defp seed_value(rest, original, skip, stack, value) do
    stack = [{:seed, value} | stack]
    rank(rest, original, skip, stack)
  end

  defp continue(rest, original, skip, stack, value) do
    case stack do
      [@rank | stack] ->
        rank_value(rest, original, skip, stack, value)

      [@seed | stack] ->
        seed_value(rest, original, skip, stack, value)
    end
  end

  defp error(_original, skip) do
    throw({:position, skip})
  end
end
