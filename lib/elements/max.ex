defmodule Seedparser.Element.Max do
  @moduledoc false

  @digits '01234556789'
  @spaces '\s\t,.&'
  @quantity 0
  @seed 1

  alias Seedparser.DecodeError
  alias Seedparser.Normalizer
  alias Seedparser.Element.TypeToken

  def decode(data) do
    try do
      quantity(data, data, 0, [])
    catch
      {:position, position} ->
        {:error, %DecodeError{position: position, data: data}}
    else
      [] ->
        TypeToken.decode(data)

      value ->
        {:ok,
         value
         |> Normalizer.normalize()
         |> Enum.into(%{})}
    end
  end

  defp quantity(<<byte, rest::bits>>, original, skip, stack) when byte in @digits do
    quantity(rest, original, skip, [@quantity | stack], 1)
  end

  defp quantity(<<_, rest::bits>>, original, skip, stack) do
    quantity(rest, original, skip + 1, stack)
  end

  defp quantity(<<>>, _original, _skip, stack) do
    stack
  end

  defp quantity(<<byte, rest::bits>>, original, skip, stack, len) when byte in @digits do
    quantity(rest, original, skip, stack, len + 1)
  end

  defp quantity(<<byte, rest::bits>>, original, skip, stack, len) when byte in @spaces do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(rest, original, skip + len, stack, value)
  end

  defp quantity(<<_::bits>>, original, skip, _stack, len) do
    error(original, skip + len)
  end

  defp quantity(<<>>, original, skip, _stack, len) do
    error(original, skip + len)
  end

  defp seed(<<byte, rest::bits>>, original, skip, stack) when byte in @spaces do
    seed(rest, original, skip + 1, stack)
  end

  defp seed(<<_, rest::bits>>, original, skip, stack) do
    seed(rest, original, skip + 1, stack, 1)
  end

  defp seed(<<byte, rest::bits>>, original, skip, stack, len) when byte in @spaces do
    value =
      original
      |> binary_part(skip, len)

    continue(rest, original, skip + 1 + len, stack, value)
  end

  defp seed(<<_, rest::bits>>, original, skip, stack, len) do
    seed(rest, original, skip, stack, len + 1)
  end

  defp seed(<<>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)

    continue(<<>>, original, skip + 1 + len, stack, value)
  end

  defp quantity_value(rest, original, skip, stack, value) do
    stack = [@seed, {:quantity, value} | stack]
    seed(rest, original, skip, stack)
  end

  defp seed_value(rest, original, skip, stack, value) do
    [{:quantity, quantity} | stack] = stack
    stack = [{value, quantity} | stack]
    quantity(rest, original, skip, stack)
  end

  defp continue(rest, original, skip, stack, value) do
    case stack do
      [@quantity | stack] ->
        quantity_value(rest, original, skip, stack, value)

      [@seed | stack] ->
        seed_value(rest, original, skip, stack, value)
    end
  end

  defp error(_original, skip) do
    throw({:position, skip})
  end
end
