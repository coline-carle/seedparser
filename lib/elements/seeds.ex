defmodule Seedparser.Element.Seeds do
  @moduledoc false

  @digits '01234556789'
  @seeds_quantity 0

  alias Seedparser.DecodeError

  def decode(data) do
    try do
      seeds(data, data, 0, [@seeds_quantity], 0)
    catch
      {:position, position} ->
        {:error, %DecodeError{position: position, data: data}}
    else
      value ->
        {:ok, value |> Enum.into(%{})}
    end
  end

  defp seeds(<<byte, rest::bits>>, original, skip, stack, len) when byte in @digits do
    seeds(rest, original, skip, stack, len + 1)
  end

  defp seeds(<<byte, _::bits>>, original, skip, stack, len) when byte in '\s\t' do
    seeds("", original, skip, stack, len)
  end

  defp seeds(<<>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(<<>>, original, skip, stack, value)
  end

  defp seeds(<<_::bits>>, original, skip, _stack, len) do
    error(original, skip + len)
  end

  defp seeds_value(_rest, _original, _skip, _stack, value) do
    [{:quantity, value}]
  end

  defp continue(rest, original, skip, stack, value) do
    case stack do
      [@seeds_quantity | stack] ->
        seeds_value(rest, original, skip, stack, value)
    end
  end

  defp error(_original, skip) do
    throw({:position, skip})
  end
end
