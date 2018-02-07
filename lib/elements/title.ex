defmodule SeedParser.Element.Title do
  @moduledoc false
  require Logger

  @digits '01234556789'
  @text 1
  @number 2

  @spaces '\s\t,.&/'
  @tokens %{
    "slr" => :starlight_rose,
    "foxflower" => :foxflower,
    "ff" => :foxflower,
    "fox" => :foxflower,
    "mix" => :mix,
    "mixed" => :mix
  }

  @type raid_type ::
          :starlight_rose
          | :foxflower
          | :mix

  @spec decode(binary()) :: {:ok, {raid_type, integer()}} | {:error, atom()}
  def decode(data) do
    data
    |> node(data, 0, [])
    |> post_decode
  end

  defp post_decode([{:token, token}, {:number, value} | _]) do
    {:ok, {token, value}}
  end

  defp post_decode([_any | rest]) do
    post_decode(rest)
  end

  defp post_decode([]) do
    {:error, :invalid_title}
  end

  defp node(<<byte, rest::bits>>, original, skip, stack) when byte in @spaces do
    node(rest, original, skip + 1, stack)
  end

  defp node(<<byte, rest::bits>>, original, skip, stack) when byte in @digits do
    number(rest, original, skip, [@number | stack], 1)
  end

  defp node(<<_, rest::bits>>, original, skip, stack) do
    text(rest, original, skip, [@text | stack], 1)
  end

  defp node(<<>>, _original, _skip, stack) do
    stack
  end

  defp number(<<byte, rest::bits>>, original, skip, stack, len) when byte in @digits do
    number(rest, original, skip, stack, len + 1)
  end

  defp number(<<_, rest::bits>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(rest, original, skip + len + 1, stack, value)
  end

  defp number(<<>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(<<>>, original, skip + len, stack, value)
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
    case tokenize(value) do
      :unknown ->
        stack = [{:unknown, value} | stack]

      token ->
        stack = [{:token, token} | stack]
    end

    node(rest, original, skip, stack)
  end

  defp number_value(rest, original, skip, stack, value) do
    stack = [{:number, value} | stack]
    node(rest, original, skip, stack)
  end

  defp continue(rest, original, skip, stack, value) do
    case stack do
      [@text | stack] ->
        text_value(rest, original, skip, stack, value)

      [@number | stack] ->
        number_value(rest, original, skip, stack, value)
    end
  end
end
