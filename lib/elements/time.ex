defmodule SeedParser.Element.Time do
  defguard is_hour(value) when is_integer(value) and value >= 0 and value <= 24
  defguard is_minute(value) when is_integer(value) and value >= 0 and value <= 60
  @moduledoc false

  @digits '01234556789'
  @hour 0
  @minute 1

  alias SeedParser.DecodeError

  @type t :: {Calendar.hour(), Calendar.minute(), Calendar.second()}

  @spec decode(binary()) :: {:ok, t} | {:error, atom()}
  def decode(data) do
    try do
      hour(data, data, 0, [])
    catch
      {:position, position} ->
        {:error, %DecodeError{position: position, data: data}}
    else
      value ->
        value
        |> Enum.into(%{})
        |> post_decode
    end
  end

  defp post_decode(%{hour: hour, minute: minute}) when is_hour(hour) and is_minute(minute) do
    {:ok, {hour, minute, 0}}
  end

  defp post_decode(_) do
    {:error, :invalid_time}
  end

  defp minute(<<byte, rest::bits>>, original, skip, stack, len) when byte in @digits do
    minute(rest, original, skip, stack, len + 1)
  end

  defp minute(<<byte, _::bits>>, original, skip, stack, len) when byte in '\s\t' do
    minute(<<>>, original, skip, stack, len)
  end

  defp minute(<<>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(<<>>, original, skip, stack, value)
  end

  defp minute(<<_::bits>>, original, skip, _stack, len) do
    error(original, skip + len)
  end

  defp hour(<<byte, rest::bits>>, original, skip, stack) when byte in @digits do
    hour(rest, original, skip, [@hour | stack], 1)
  end

  defp hour(<<_, rest::bits>>, original, skip, stack) do
    hour(rest, original, skip + 1, stack)
  end

  defp hour(<<>>, original, skip, _stack) do
    error(original, skip)
  end

  defp hour(<<byte, rest::bits>>, original, skip, stack, len) when byte in @digits do
    hour(rest, original, skip, stack, len + 1)
  end

  defp hour(<<?:, rest::bits>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(rest, original, skip + 1 + len, stack, value)
  end

  defp hour(<<_::bits>>, original, skip, _stack, len) do
    error(original, skip + len)
  end

  defp hour_value(rest, original, skip, stack, value) do
    stack = [@minute, {:hour, value} | stack]
    minute(rest, original, skip, stack, 0)
  end

  defp minute_value(_rest, _original, _skip, stack, value) do
    [{:minute, value} | stack]
  end

  defp continue(rest, original, skip, stack, value) do
    case stack do
      [@hour | stack] ->
        hour_value(rest, original, skip, stack, value)

      [@minute | stack] ->
        minute_value(rest, original, skip, stack, value)
    end
  end

  defp error(_original, skip) do
    throw({:position, skip})
  end
end
