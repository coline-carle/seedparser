defmodule SeedParser.Element.Date do
  @moduledoc false

  @digits '01234556789'
  @spaces '\s\t,.&/'
  @number 0
  @text 1
  @numdate [:month, :year]
  @litteraldate [:day]

  alias SeedParser.DecodeError
  require Logger

  @tokens %{
    "monday" => {:weekday, :monday},
    "tuesday" => {:weekday, :tuesday},
    "wednesday" => {:weekday, :wednesday},
    "thursday" => {:weekday, :thursday},
    "friday" => {:weekday, :friday},
    "saturday" => {:weekday, :saturday},
    "sunday" => {:weekday, :sunday},
    "january" => {:month, 1},
    "february" => {:month, 2},
    "march" => {:month, 3},
    "april" => {:month, 4},
    "may" => {:month, 5},
    "june" => {:month, 6},
    "july" => {:month, 7},
    "august" => {:month, 8},
    "september" => {:month, 9},
    "october" => {:month, 10},
    "november" => {:month, 11},
    "december" => {:month, 12}
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
         |> Enum.reverse()
         |> postprocess([])
         |> Enum.into(%{})}
    end
  end

  defp postprocess([node | rest], acc) do
    case node do
      {:weekday, _} ->
        postprocess(rest, [node | acc])

      {:number, number} ->
        node = {:day, number}
        postprocess_date(rest, @numdate, [node | acc])

      {:month, _} ->
        postprocess_date(rest, @litteraldate, [node | acc])
    end
  end

  defp postprocess_date([node | rest], [node_type | type_rest], acc) do
    case node do
      {_, value} ->
        acc = [{node_type, value} | acc]
        postprocess_date(rest, type_rest, acc)

      _ ->
        postprocess_date(rest, [node_type | type_rest], acc)
    end
  end

  defp postprocess_date([], _, acc), do: acc
  defp postprocess_date(_, [], acc), do: acc

  defp tokenize(node) when is_binary(node) do
    value = node |> String.downcase()

    @tokens |> Map.get(value, :unknown)
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

  defp number(<<>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(<<>>, original, skip + len, stack, value)
  end

  defp number(<<_, rest::bits>>, original, skip, stack, len) do
    value =
      original
      |> binary_part(skip, len)
      |> String.to_integer()

    continue(rest, original, skip + len + 1, stack, value)
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

  defp text_value(rest, original, skip, stack, value) do
    case tokenize(value) do
      :invalid ->
        node(rest, original, skip, stack)

      token ->
        stack = [token | stack]
        node(rest, original, skip, stack)
    end
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
