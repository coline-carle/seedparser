defmodule SeedParser.Element.Participants do
  @moduledoc false

  @digits '01234556789'
  @participants 0
  @participants_max 1

  alias SeedParser.DecodeError

  def decode(data) do
    try do
      participants(data, data, 0, [@participants], 0)
    catch
      {:position, position} ->
        {:error, %DecodeError{position: position, data: data}}
    else
      value ->
        {:ok, value |> Enum.into(%{})}
    end
  end

  defp participants_max(<<byte, rest::bits>>, original, skip, stack, len) when byte in @digits do
    participants_max(rest, original, skip, stack, len + 1)
  end

  defp participants_max(<<byte, _::bits>>, original, skip, stack, len) when byte in '\s\t' do
    participants_max("", original, skip, stack, len)
  end

  defp participants_max(<<>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(<<>>, original, skip, stack, value)
  end

  defp participants_max(<<_::bits>>, original, skip, _stack, len) do
    error(original, skip + len)
  end

  defp participants(<<byte, rest::bits>>, original, skip, stack, len) when byte in @digits do
    participants(rest, original, skip, stack, len + 1)
  end

  defp participants(<<?/, rest::bits>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(rest, original, skip + 1 + len, stack, value)
  end

  defp participants(<<_::bits>>, original, skip, _stack, len) do
    error(original, skip + len)
  end

  defp participants_value(rest, original, skip, stack, value) do
    stack = [@participants_max, {:count, value} | stack]
    participants_max(rest, original, skip, stack, 0)
  end

  defp participants_max_value(_rest, _original, _skip, stack, value) do
    [{:max, value} | stack]
  end

  defp continue(rest, original, skip, stack, value) do
    case stack do
      [@participants | stack] ->
        participants_value(rest, original, skip, stack, value)

      [@participants_max | stack] ->
        participants_max_value(rest, original, skip, stack, value)
    end
  end

  defp error(_original, skip) do
    throw({:position, skip})
  end
end
